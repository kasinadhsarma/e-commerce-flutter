import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum RewardType {
  pointsBonus,
  discount,
  freeItem,
  specialOffer,
}

class LoyaltyReward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final RewardType type;
  final Map<String, dynamic> rewardData;
  final DateTime? expirationDate;
  final bool isActive;

  LoyaltyReward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.type,
    required this.rewardData,
    this.expirationDate,
    this.isActive = true,
  });

  factory LoyaltyReward.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return LoyaltyReward(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      pointsCost: data['pointsCost'] ?? 0,
      type: RewardType.values.firstWhere(
        (t) => t.toString() == 'RewardType.${data['type']}',
        orElse: () => RewardType.discount,
      ),
      rewardData: data['rewardData'] ?? {},
      expirationDate: data['expirationDate'] != null
          ? (data['expirationDate'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
    );
  }
}

class LoyaltyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user's current loyalty points
  Future<int> getUserPoints() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return 0;
    }

    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      return 0;
    }

    return userDoc.data()?['loyaltyPoints'] ?? 0;
  }

  // Get available rewards that user can redeem
  Future<List<LoyaltyReward>> getAvailableRewards() async {
    final snapshot = await _firestore
        .collection('loyalty_rewards')
        .where('isActive', isEqualTo: true)
        .get();

    final now = DateTime.now();

    return snapshot.docs
        .map((doc) => LoyaltyReward.fromFirestore(doc))
        .where((reward) =>
            reward.expirationDate == null ||
            reward.expirationDate!.isAfter(now))
        .toList();
  }

  // Get user's redeem history
  Future<List<Map<String, dynamic>>> getRedeemHistory() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('reward_redemptions')
        .orderBy('redeemedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'rewardId': data['rewardId'],
        'rewardTitle': data['rewardTitle'],
        'pointsSpent': data['pointsSpent'],
        'redeemedAt': (data['redeemedAt'] as Timestamp).toDate(),
        'usedAt': data['usedAt'] != null
            ? (data['usedAt'] as Timestamp).toDate()
            : null,
        'expired': data['expired'] ?? false,
      };
    }).toList();
  }

  // Redeem a reward
  Future<bool> redeemReward(String rewardId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return false;
    }

    // Get user's current points
    final userPoints = await getUserPoints();

    // Get the reward details
    final rewardDoc =
        await _firestore.collection('loyalty_rewards').doc(rewardId).get();

    if (!rewardDoc.exists) {
      return false;
    }

    final reward = LoyaltyReward.fromFirestore(rewardDoc);

    // Check if user has enough points
    if (userPoints < reward.pointsCost) {
      return false;
    }

    // Perform transaction to deduct points and record redemption
    final result = await _firestore.runTransaction<bool>((transaction) async {
      // Deduct points from user
      transaction.update(
        _firestore.collection('users').doc(userId),
        {'loyaltyPoints': FieldValue.increment(-reward.pointsCost)},
      );

      // Record redemption
      final redemptionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('reward_redemptions')
          .doc();

      transaction.set(redemptionRef, {
        'rewardId': reward.id,
        'rewardTitle': reward.title,
        'rewardType': reward.type.toString().split('.').last,
        'pointsSpent': reward.pointsCost,
        'redeemedAt': FieldValue.serverTimestamp(),
        'usedAt': null,
        'expired': false,
        'rewardData': reward.rewardData,
        'expirationDate': reward.expirationDate,
      });

      return true;
    });

    return result;
  }

  // Mark a redemption as used
  Future<void> markRedemptionAsUsed(String redemptionId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('reward_redemptions')
        .doc(redemptionId)
        .update({
      'usedAt': FieldValue.serverTimestamp(),
    });
  }

  // Check progress toward next tier or special reward
  Future<Map<String, dynamic>> getLoyaltyProgress() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return {
        'currentPoints': 0,
        'nextRewardAt': 100,
        'progress': 0.0,
      };
    }

    final userPoints = await getUserPoints();

    // Get loyalty tiers from the system
    final tiersDoc =
        await _firestore.collection('system').doc('loyalty_tiers').get();
    final tiers = tiersDoc.data()?['tiers'] as List? ?? [];

    // Default next reward at 100 points
    int nextRewardAt = 100;

    // Find the next tier based on user's points
    if (tiers.isNotEmpty) {
      tiers.sort((a, b) => a['pointsRequired'] - b['pointsRequired']);

      for (final tier in tiers) {
        if (tier['pointsRequired'] > userPoints) {
          nextRewardAt = tier['pointsRequired'];
          break;
        }
      }
    }

    return {
      'currentPoints': userPoints,
      'nextRewardAt': nextRewardAt,
      'progress': userPoints / nextRewardAt,
    };
  }

  // Add bonus points for special promotions
  Future<void> addBonusPoints(int points, String reason) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return;
    }

    // Add points to user
    await _firestore.collection('users').doc(userId).update({
      'loyaltyPoints': FieldValue.increment(points),
    });

    // Record the transaction
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('point_transactions')
        .add({
      'points': points,
      'type': 'bonus',
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
