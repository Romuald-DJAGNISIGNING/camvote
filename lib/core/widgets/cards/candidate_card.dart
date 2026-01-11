import 'package:flutter/material.dart';
import '../../theme/cam_colors.dart';
import '../../theme/cam_text_styles.dart';

/// Card displaying candidate information during voting
class CandidateCard extends StatelessWidget {
  final String candidateName;
  final String party;
  final String? photoUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const CandidateCard({
    super.key,
    required this.candidateName,
    required this.party,
    this.photoUrl,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? CamColors.green : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Candidate Photo
              CircleAvatar(
                radius: 30,
                backgroundColor: CamColors.lightGrey,
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 30, color: CamColors.grey)
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Candidate Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidateName,
                      style: CamTextStyles.h3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      party,
                      style: CamTextStyles.caption,
                    ),
                  ],
                ),
              ),
              
              // Selection Indicator
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: CamColors.green,
                  size: 32,
                ),
            ],
          ),
        ),
      ),
    );
  }
}