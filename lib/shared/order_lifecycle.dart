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

  static const ownerDirectTransitions = <String, Set<String>>{
    pending: {accepted, cancelled},
    accepted: {ready, cancelled},
    ready: {cancelled},
  };

  static const terminal = {delivered, cancelled};

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

  static bool isTerminal(String status) =>
      terminal.contains(normalizeStatus(status));

  static bool canTransition({
    required String from,
    required String to,
  }) {
    final current = normalizeStatus(from);
    final next = normalizeStatus(to);
    return ownerDirectTransitions[current]?.contains(next) ?? false;
  }

  static bool canCustomerCancel(String status) =>
      normalizeStatus(status) == pending;

  static bool canOwnerCancel(String status) {
    switch (normalizeStatus(status)) {
      case pending:
      case accepted:
      case ready:
        return true;
      default:
        return false;
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

  static String label(String status, {dynamic l10n}) {
    final norm = normalizeStatus(status);
    if (l10n != null) {
      try {
        switch (norm) {
          case pending:
            return l10n.statusFindingShop;
          case accepted:
            return l10n.statusPreparing;
          case ready:
            return l10n.statusReady;
          case shipping:
            return l10n.statusShipping;
          case outForDelivery:
            return l10n.statusRiderNearby;
          case delivered:
            return l10n.statusDelivered;
          case cancelled:
            return l10n.statusCancelled;
        }
      } catch (_) {
        // Fallback if l10n doesn't have the keys
      }
    }

    switch (norm) {
      case pending:
        return 'Finding Shop';
      case accepted:
        return 'Preparing';
      case ready:
        return 'Ready for pickup';
      case shipping:
        return 'On the way';
      case outForDelivery:
        return 'Rider is nearby';
      case delivered:
        return 'Delivered';
      case cancelled:
        return 'Cancelled';
      default:
        final raw = norm.replaceAll('_', ' ');
        if (raw.isEmpty) return raw;
        return raw[0].toUpperCase() + raw.substring(1);
    }
  }
}
