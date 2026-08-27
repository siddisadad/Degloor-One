import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';

void main() {
  test('normalizes retired checkout statuses onto pending / unpaid', () {
    expect(OrderLifecycle.normalizeStatus('placed'), OrderLifecycle.pending);
    expect(OrderLifecycle.normalizeStatus('CREATED'), OrderLifecycle.pending);
    expect(OrderLifecycle.normalizePayment('pending'), OrderLifecycle.unpaid);
    expect(OrderLifecycle.stepperIndex('placed'), 0);
    expect(OrderLifecycle.stepperIndex('out_for_delivery'), 3);
    expect(OrderLifecycle.stepperIndex('cancelled'), -1);
    expect(OrderLifecycle.label('out_for_delivery'), 'Rider is nearby');
    expect(OrderLifecycle.label('shipping'), 'On the way');
    expect(OrderLifecycle.label('pending'), 'Finding Shop');
  });

  test('owner transitions and cancel rules', () {
    expect(
      OrderLifecycle.canTransition(
        from: OrderLifecycle.pending,
        to: OrderLifecycle.accepted,
      ),
      isTrue,
    );
    expect(
      OrderLifecycle.canTransition(
        from: OrderLifecycle.pending,
        to: OrderLifecycle.ready,
      ),
      isFalse,
    );
    expect(
      OrderLifecycle.canTransition(
        from: OrderLifecycle.pending,
        to: OrderLifecycle.delivered,
      ),
      isFalse,
    );
    expect(OrderLifecycle.canCustomerCancel(OrderLifecycle.pending), isTrue);
    expect(OrderLifecycle.canCustomerCancel(OrderLifecycle.accepted), isFalse);
    expect(OrderLifecycle.canOwnerCancel(OrderLifecycle.ready), isTrue);
    expect(OrderLifecycle.canOwnerCancel(OrderLifecycle.shipping), isFalse);
    expect(OrderLifecycle.isTerminal(OrderLifecycle.delivered), isTrue);
  });
}
