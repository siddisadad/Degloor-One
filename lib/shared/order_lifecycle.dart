/// Canonical order + payment statuses used by checkout, tracking, and RLS.
class OrderLifecycle {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const ready = 'ready';
  static const shipping = 'shipping';
  static const outForDelivery = 'out_for_delivery';
  static const delivered = 'delivered';
  static const cancelled = 'cancelled';

  static const unpaid = 'unpaid';
  static const paid = 'paid';

  static const ownerStatuses = {
    pending,
    accepted,
    ready,
    shipping,
    outForDelivery,
    delivered,
    cancelled,
  };

  static String normalizeStatus(String status) {
    switch (status.toLowerCase().trim()) {
      case 'placed':
      case 'created':
        return pending;
      case 'out for delivery':
        return outForDelivery;
      default:
        return status.toLowerCase().trim();
    }
  }

  static String normalizePayment(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
      case 'cod':
        return unpaid;
      default:
        return status.toLowerCase().trim();
    }
  }

  static int stepperIndex(String status) {
    switch (normalizeStatus(status)) {
      case pending:
        return 0;
      case accepted:
        return 1;
      case ready:
        return 2;
      case shipping:
      case outForDelivery:
        return 3;
      case delivered:
        return 4;
      case cancelled:
        return -1;
      default:
        return 0;
    }
  }

  static String label(String status) {
    return normalizeStatus(status).replaceAll('_', ' ');
  }
}
