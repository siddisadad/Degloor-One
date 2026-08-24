import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';

void main() {
  test('JobListing reads the shop join', () {
    final job = JobListing.fromJoin({
      'id': 'job-1',
      'title': 'Counter assistant',
      'job_type': 'Part-time',
      'salary_range': '₹8,000',
      'businesses': {
        'name': 'Patil Kirana',
        'location': 'Main Road',
      },
    });
    expect(job.shop?.displayName, 'Patil Kirana');
    expect(job.shop?.displayLocation, 'Main Road');
  });

  test('ServiceProviderCard reads user and category joins', () {
    final provider = ServiceProviderCard.fromJoin({
      'id': 'sp-ravi',
      'category_id': 'scat-electric',
      'hourly_rate': 400,
      'is_verified': true,
      'users': {'full_name': 'Ravi', 'avatar_url': 'https://example.com/a.png'},
      'service_categories': {'name': 'Electrician'},
    });
    expect(provider.displayName, 'Ravi');
    expect(provider.categoryName, 'Electrician');
    expect(provider.isVerified, isTrue);
    expect(provider.hourlyRate, 400);
    expect(provider.hourlyRateLabel, '₹400/hr');
    expect(
      ServiceProviderCard.fromJoin({
        'id': 'sp-string-rate',
        'hourly_rate': '450.5',
        'experience_years': '10',
      }).hourlyRate,
      450.5,
    );
    expect(provider.avatarImageUrl(), 'https://example.com/a.png');
  });

  test('ServiceProviderCard falls back when join photo or rate is missing', () {
    final provider = ServiceProviderCard.fromJoin({
      'id': 'sp-anon',
      'hourly_rate': 99.5,
    });
    expect(provider.displayName, 'Unknown Provider');
    expect(provider.categoryName, 'General');
    expect(provider.hourlyRateLabel, '₹99.50/hr');
    expect(provider.photoUrl, isNull);
    expect(provider.avatarImageUrl(width: 400, height: 300), isEmpty);
    expect(
      const ServiceProviderCard(id: 'sp-none').hourlyRateLabel,
      'Rate on request',
    );
  });

  test('ShopReview uses the reviewer join and stored rating', () {
    final review = ShopReview.fromJoin({
      'id': 'rv-1',
      'user_id': 'user-1',
      'rating': 5,
      'comment': 'Good shop',
      'created_at': '2026-01-01T00:00:00.000Z',
      'users': {'full_name': 'Asha Patil'},
    });
    expect(review.authorName, 'Asha Patil');
    expect(review.initials, 'AP');
    expect(review.rating, 5);
    expect(ShopReview.fromJoin({'id': 'rv-2', 'rating': 4}).authorName, 'Anonymous');
  });

  test('ServiceProviderCard maps Java provider JSON onto the user join', () {
    final card = ServiceProviderCard.fromJson({
      'id': 'sp-ravi',
      'userId': 'user-electrician',
      'fullName': 'Ravi',
      'phoneNumber': '9876543210',
      'avatarUrl': 'https://example.com/a.png',
    });
    expect(card.displayName, 'Ravi');
    expect(card.user?.phoneNumber, '9876543210');
    expect(card.photoUrl, 'https://example.com/a.png');
    expect(
      ServiceProviderCard.fromJson({'id': 'sp-anon'}).displayName,
      'Unknown Provider',
    );
  });

  test('JobApplicant maps Java applicant JSON onto the user join', () {
    final applicant = JobApplicant.fromJson({
      'id': 'app-1',
      'status': 'applied',
      'experienceSummary': 'Counter work',
      'fullName': 'Ravi',
      'phoneNumber': '9876543210',
    });
    expect(applicant.user?.displayName(fallback: 'Unknown Applicant'), 'Ravi');
    expect(applicant.user?.phoneNumber, '9876543210');
    expect(
      JobApplicant.fromJson({'id': 'app-2', 'status': 'applied'}).user,
      isNull,
    );
  });
}
