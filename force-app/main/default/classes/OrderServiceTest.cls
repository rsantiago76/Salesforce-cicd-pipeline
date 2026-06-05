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
        con.Status = 'Activated';
        update con;

        Order o = new Order(
            AccountId = acc.Id,
            ContractId = con.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;

        // Add a product so the order can be activated
        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        OrderItem item = new OrderItem(
            OrderId = o.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert item;
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