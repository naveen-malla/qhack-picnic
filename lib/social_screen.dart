import 'dart:math' as math;

import 'package:flutter/material.dart';

class SocialMetric {
  const SocialMetric({required this.value, required this.label});

  final String value;
  final String label;
}

class SocialIngredientLine {
  const SocialIngredientLine({required this.name, required this.detail});

  final String name;
  final String detail;
}

class SocialRecipePostData {
  const SocialRecipePostData({
    required this.authorName,
    required this.authorSubtitle,
    required this.dayLabel,
    required this.title,
    required this.caption,
    required this.imageAssetPath,
    required this.metrics,
    required this.ingredients,
    required this.likes,
    required this.comments,
    required this.tipLabel,
  });

  final String authorName;
  final String authorSubtitle;
  final String dayLabel;
  final String title;
  final String caption;
  final String imageAssetPath;
  final List<SocialMetric> metrics;
  final List<SocialIngredientLine> ingredients;
  final int likes;
  final int comments;
  final String tipLabel;
}

class SocialChallengePostData {
  const SocialChallengePostData({
    required this.authorName,
    required this.authorSubtitle,
    required this.title,
    required this.description,
    required this.rewardLabel,
    required this.participantCount,
    required this.likes,
    required this.communityImagePaths,
  });

  final String authorName;
  final String authorSubtitle;
  final String title;
  final String description;
  final String rewardLabel;
  final int participantCount;
  final int likes;
  final List<String> communityImagePaths;
}

class SocialScreen extends StatefulWidget {
  const SocialScreen({
    super.key,
    required this.recipePost,
    required this.challengePost,
    required this.onAddRecipeItems,
    required this.onAddChallengeStarterKit,
  });

  final SocialRecipePostData recipePost;
  final SocialChallengePostData challengePost;
  final VoidCallback onAddRecipeItems;
  final VoidCallback onAddChallengeStarterKit;

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  bool _isRecipeFlipped = false;
  bool _joinedChallenge = false;
  late int _challengeParticipants;

  @override
  void initState() {
    super.initState();
    _challengeParticipants = widget.challengePost.participantCount;
  }

  void _toggleChallengeJoined() {
    setState(() {
      if (_joinedChallenge) {
        _challengeParticipants = math.max(
          widget.challengePost.participantCount,
          _challengeParticipants - 1,
        );
      } else {
        _challengeParticipants += 1;
      }
      _joinedChallenge = !_joinedChallenge;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      key: const Key('socialFeedList'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Text('Social', style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          'Rezepte, Challenges und schnelle Warenkorb-Ideen aus der Community.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF6D645F),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 18),
        _RecipePostCard(
          data: widget.recipePost,
          isFlipped: _isRecipeFlipped,
          onFlip: () => setState(() => _isRecipeFlipped = !_isRecipeFlipped),
          onAddToBasket: widget.onAddRecipeItems,
        ),
        const SizedBox(height: 16),
        _ChallengePostCard(
          data: widget.challengePost,
          joined: _joinedChallenge,
          participantCount: _challengeParticipants,
          onToggleJoined: _toggleChallengeJoined,
          onAddStarterKit: widget.onAddChallengeStarterKit,
        ),
      ],
    );
  }
}

class _RecipePostCard extends StatelessWidget {
  const _RecipePostCard({
    required this.data,
    required this.isFlipped,
    required this.onFlip,
    required this.onAddToBasket,
  });

  final SocialRecipePostData data;
  final bool isFlipped;
  final VoidCallback onFlip;
  final VoidCallback onAddToBasket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFF6D8DB),
                  child: Icon(
                    Icons.emoji_food_beverage_rounded,
                    color: Color(0xFFE53935),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.authorName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.authorSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF7B726C),
                        ),
                      ),
                    ],
                  ),
                ),
                _PostTag(label: data.dayLabel),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              data.title,
              style: theme.textTheme.titleLarge?.copyWith(height: 1.0),
            ),
            const SizedBox(height: 6),
            Text(
              data.caption,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6D645F),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    key: const Key('socialRecipeFlipArea'),
                    onTap: onFlip,
                    child: _RecipeFlipPanel(
                      data: data,
                      isFlipped: isFlipped,
                      onAddToBasket: onAddToBasket,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 86,
                  child: Column(
                    children: [
                      for (final metric in data.metrics) ...[
                        _MetricCard(metric: metric),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0EB),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.touch_app_rounded,
                    size: 18,
                    color: Color(0xFF7A716B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.tipLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6D645F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _PostStat(
                  icon: Icons.favorite_border_rounded,
                  label: '${data.likes}',
                ),
                const SizedBox(width: 16),
                _PostStat(
                  icon: Icons.mode_comment_outlined,
                  label: '${data.comments}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeFlipPanel extends StatelessWidget {
  const _RecipeFlipPanel({
    required this.data,
    required this.isFlipped,
    required this.onAddToBasket,
  });

  final SocialRecipePostData data;
  final bool isFlipped;
  final VoidCallback onAddToBasket;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.76,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: isFlipped ? math.pi : 0),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
        builder: (context, value, _) {
          final isBackVisible = value > (math.pi / 2);
          final rotation = isBackVisible ? value - math.pi : value;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(rotation),
            child: isBackVisible
                ? _RecipeBackFace(
                    data: data,
                    onAddToBasket: onAddToBasket,
                  )
                : _RecipeFrontFace(data: data),
          );
        },
      ),
    );
  }
}

class _RecipeFrontFace extends StatelessWidget {
  const _RecipeFrontFace({required this.data});

  final SocialRecipePostData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            data.imageAssetPath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFF0E8DD),
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_outlined,
                size: 44,
                color: Color(0xFFB7ADA6),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x22000000), Color(0xCC000000)],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Tippen',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5B534E),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community Bowl',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeBackFace extends StatelessWidget {
  const _RecipeBackFace({
    required this.data,
    required this.onAddToBasket,
  });

  final SocialRecipePostData data;
  final VoidCallback onAddToBasket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4EDE6),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF3E7D2A),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Zutaten',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '1 Portion',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6D645F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final ingredient in data.ingredients) ...[
            _IngredientRow(ingredient: ingredient),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 2),
          FilledButton(
            key: const Key('socialRecipeAddButton'),
            onPressed: onAddToBasket,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Alle Zutaten hinzufügen',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Alle Zutaten werden jeweils 1x hinzugefugt.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6D645F),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.ingredient});

  final SocialIngredientLine ingredient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            '1',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFFE53935),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${ingredient.name} · ${ingredient.detail}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF4E4641),
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChallengePostCard extends StatelessWidget {
  const _ChallengePostCard({
    required this.data,
    required this.joined,
    required this.participantCount,
    required this.onToggleJoined,
    required this.onAddStarterKit,
  });

  final SocialChallengePostData data;
  final bool joined;
  final int participantCount;
  final VoidCallback onToggleJoined;
  final VoidCallback onAddStarterKit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF2DE), Color(0xFFF8EEE3)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.flag_rounded,
                    color: Color(0xFF3E7D2A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.authorName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.authorSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6D645F),
                        ),
                      ),
                    ],
                  ),
                ),
                _PostTag(label: 'Challenge'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.78),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.95),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: theme.textTheme.titleLarge?.copyWith(height: 1.0),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5E5550),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ChallengeInfoPill(
                          icon: Icons.local_fire_department_outlined,
                          label: '$participantCount machen schon mit',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ChallengeInfoPill(
                          icon: Icons.card_giftcard_rounded,
                          label: data.rewardLabel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          key: const Key('socialChallengeJoinButton'),
                          onPressed: onToggleJoined,
                          style: FilledButton.styleFrom(
                            backgroundColor: joined
                                ? const Color(0xFF3E7D2A)
                                : const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            joined ? 'Du bist dabei' : 'Ich bin dabei',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('socialChallengeCartButton'),
                          onPressed: onAddStarterKit,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3E7D2A),
                            minimumSize: const Size.fromHeight(50),
                            side: const BorderSide(
                              color: Color(0xFFB5CEA1),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: const Icon(Icons.shopping_basket_outlined),
                          label: const Text(
                            'Starter-Kit',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                ...data.communityImagePaths.map(
                  (imagePath) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CommunityThumb(imagePath: imagePath),
                  ),
                ),
                const Spacer(),
                _PostStat(
                  icon: Icons.favorite_border_rounded,
                  label: '${data.likes}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final SocialMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            metric.value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            metric.label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7A716B),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostTag extends StatelessWidget {
  const _PostTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF5B534E),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _PostStat extends StatelessWidget {
  const _PostStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6D645F)),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5B534E),
              ),
        ),
      ],
    );
  }
}

class _ChallengeInfoPill extends StatelessWidget {
  const _ChallengeInfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4B6B1F)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF4B6B1F),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityThumb extends StatelessWidget {
  const _CommunityThumb({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 38,
        height: 38,
        color: Colors.white,
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.image_outlined,
            size: 18,
            color: Color(0xFFB7ADA6),
          ),
        ),
      ),
    );
  }
}
