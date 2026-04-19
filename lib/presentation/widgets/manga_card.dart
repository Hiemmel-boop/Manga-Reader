import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/manga.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';

// ─── CARTE HORIZONTALE (home, bibliothèque) ───────────────────────────────────
class MangaCard extends StatelessWidget {
  final Manga manga;
  final VoidCallback onTap;
  final double width;
  final double height;
  final bool showAuthor;

  const MangaCard({
    super.key,
    required this.manga,
    required this.onTap,
    this.width = 130,
    this.height = 190,
    this.showAuthor = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildCover(),
              // Dégradé + titre intégré — plus de débordement possible
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                      stops: [0.3, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        manga.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      if (showAuthor && manga.author != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          manga.author!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    if (manga.coverUrl != null) {
      return CachedNetworkImage(
        imageUrl: manga.coverUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _shimmer(),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _shimmer() => Shimmer.fromColors(
    baseColor: Colors.grey[800]!,
    highlightColor: Colors.grey[600]!,
    child: Container(color: Colors.grey[800]),
  );

  Widget _placeholder() => Container(
    color: Colors.grey[850],
    child: const Icon(Icons.menu_book, color: Colors.grey, size: 40),
  );
}

// ─── CARTE GRILLE (library, search) ──────────────────────────────────────────
class MangaGridCard extends StatelessWidget {
  final Manga manga;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const MangaGridCard({
    super.key,
    required this.manga,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: onTap,
            child: manga.coverUrl != null
                ? CachedNetworkImage(
              imageUrl: manga.coverUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[600]!,
                child: Container(color: Colors.grey[800]),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey[850],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            )
                : Container(
              color: Colors.grey[850],
              child: const Icon(Icons.book, color: Colors.grey, size: 40),
            ),
          ),

          // Badge statut
          if (manga.status != null)
            Positioned(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.statusColor(manga.status).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  AppTheme.statusLabel(manga.status),
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

          // Dégradé + titre
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                    stops: [0.3, 1.0],
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Text(
                  manga.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ),

          // Bouton suppression
          if (onDelete != null)
            Positioned(
              top: AppSpacing.xs, left: AppSpacing.xs,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}