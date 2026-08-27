import 'package:degloor_one/backend/notification_service.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(ShowcaseCatalog.reset);

  test('sendNotification in showcase mode stores referenceId', () async {
    const userId = 'user-1';
    const orderId = 'order-123';

    await NotificationService.sendNotification(
      userId: userId,
      title: 'Order Status',
      message: 'Your order is out for delivery',
      type: 'order_status',
      referenceId: orderId,
    );

    final page = await NotificationService.instance.listForUser(userId);
    expect(page.items, hasLength(1));
    expect(page.items.first.title, 'Order Status');
    expect(page.items.first.type, 'order_status');
    expect(page.items.first.referenceId, orderId);
  });

  test('adminNotify in showcase mode stores referenceId', () async {
    const userId = 'user-1';
    const refId = 'ref-456';

    await NotificationService.adminNotify(
      userId: userId,
      title: 'Admin Alert',
      message: 'Check this out',
      type: 'general',
      referenceId: refId,
    );

    final page = await NotificationService.instance.listForUser(userId);
    expect(page.items, hasLength(1));
    expect(page.items.first.referenceId, refId);
  });

  test('notifyOrderStatusUpdate uses orderId as referenceId', () async {
    const userId = 'user-1';
    const orderId = 'ord-999';

    await NotificationService.notifyOrderStatusUpdate(
      userId: userId,
      orderId: orderId,
      status: 'Ready',
    );

    final page = await NotificationService.instance.listForUser(userId);
    expect(page.items.first.referenceId, orderId);
    expect(page.items.first.type, 'order_status');
  });
}
