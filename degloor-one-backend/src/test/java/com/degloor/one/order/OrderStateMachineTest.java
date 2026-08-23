package com.degloor.one.order;

import com.degloor.one.common.exception.BusinessException;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class OrderStateMachineTest {
    @Test
    void ownerCanAcceptPending() {
        assertTrue(OrderStateMachine.canOwnerTransition("pending", "accepted"));
        assertTrue(OrderStateMachine.canOwnerTransition("accepted", "ready"));
        assertTrue(OrderStateMachine.canOwnerTransition("ready", "cancelled"));
    }

    @Test
    void ownerCannotSkipOrDeliverDirectly() {
        assertFalse(OrderStateMachine.canOwnerTransition("pending", "ready"));
        assertFalse(OrderStateMachine.canOwnerTransition("ready", "delivered"));
        assertFalse(OrderStateMachine.canOwnerTransition("shipping", "delivered"));
        assertThrows(BusinessException.class, () -> OrderStateMachine.assertOwnerTransition("pending", "delivered"));
    }

    @Test
    void customerCancelsPendingOnly() {
        assertTrue(OrderStateMachine.canCustomerCancel("pending"));
        assertFalse(OrderStateMachine.canCustomerCancel("accepted"));
    }

    @Test
    void ownerCannotCancelAfterRider() {
        assertTrue(OrderStateMachine.canOwnerCancel("ready", false));
        assertFalse(OrderStateMachine.canOwnerCancel("ready", true));
        assertFalse(OrderStateMachine.canOwnerCancel("shipping", false));
    }

    @Test
    void deliveryConfirmableStates() {
        assertTrue(OrderStateMachine.canConfirmDelivery("ready"));
        assertTrue(OrderStateMachine.canConfirmDelivery("out_for_delivery"));
        assertFalse(OrderStateMachine.canConfirmDelivery("pending"));
        assertFalse(OrderStateMachine.canConfirmDelivery("cancelled"));
    }
}
