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
      'users': {'full_name': 'Ravi', 'avatar_url': 'https://example.com/a.png'},
      'service_categories': {'name': 'Electrician'},
    });
    expect(provider.displayName, 'Ravi');
    expect(provider.categoryName, 'Electrician');
    expect(provider.hourlyRate, 400);
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
}
