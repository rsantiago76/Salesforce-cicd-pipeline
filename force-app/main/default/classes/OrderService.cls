public with sharing class OrderService {

    public static List<Order> getOrdersByAccount(Id accountId) {
        return [
            SELECT Id, OrderNumber, Status, TotalAmount, EffectiveDate
            FROM Order
            WHERE AccountId = :accountId
            AND Status != 'Cancelled'
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];
    }

    public static Integer countOpenOrders() {
        return [SELECT COUNT() FROM Order WHERE Status = 'Draft'];
    }

    public static void activateOrder(Id orderId) {
        Order o = [SELECT Id, Status FROM Order WHERE Id = :orderId LIMIT 1];
        o.Status = 'Activated';
        update o;
    }
} 
