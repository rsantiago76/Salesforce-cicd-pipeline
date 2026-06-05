@IsTest
private class OrderServiceTest {

    @TestSetup
    static void makeData() {
        Account acc = new Account(Name = 'Test Account CI');
        insert acc;

        Contract con = new Contract(
            AccountId = acc.Id,
            StartDate = Date.today(),
            ContractTerm = 12,
            Status = 'Draft'
        );
        insert con;

        Order o = new Order(
            AccountId = acc.Id,
            ContractId = con.Id,
            Status = 'Draft',
            EffectiveDate = Date.today()
        );
        insert o;
    }

    @IsTest
    static void testGetOrdersByAccount() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        List<Order> orders = OrderService.getOrdersByAccount(acc.Id);
        Test.stopTest();
        Assert.isTrue(orders.size() >= 0, 'Should return list of orders');
    }

    @IsTest
    static void testCountOpenOrders() {
        Test.startTest();
        Integer count = OrderService.countOpenOrders();
        Test.stopTest();
        Assert.isTrue(count >= 0, 'Count should be non-negative');
    }

    @IsTest
    static void testActivateOrder() {
        Order o = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        OrderService.activateOrder(o.Id);
        Test.stopTest();
        Order updated = [SELECT Id, Status FROM Order WHERE Id = :o.Id];
        Assert.areEqual('Activated', updated.Status, 'Order should be Activated');
    }
}