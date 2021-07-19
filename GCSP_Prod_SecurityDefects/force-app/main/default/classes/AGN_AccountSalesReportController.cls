public with sharing class AGN_AccountSalesReportController {

    // Release 14.1
  public List<Product_vod__c> allProducts = new List<Product_vod__c>();  
                 
private static final String anyValue = '__any__',
                convValue = '__converted__',
                botoxProdLine = 'Botox',
                fillersProdLine = 'Fillers',
                healthOrberaProdLine = 'Health - Orbera',
                salesSalesOrderGroup = 'Sales',
                freegoodsSalesOrderGroup = 'Freegoods';
  private static final String[] allProdLines = new String[] { 'Botox', 'Breast', 'Fillers', 'Latisse', 'Health - Orbera', 'Retina', 'Pharma' },
                  yearColors = new String[] { '#0000ff', '#ff0000', '#007f00' };
  private static final Integer cnMaxYAxisSteps = 10,
                 cnMaxFillersProdNameSelOptionsSize = 10;
    Decimal dcmConversionRate{ get; private set; }

  private Boolean prAccRollup = false,
          prAccOnly = false,
          addPrev2Year = false,
          print = false;
  private Double maxQuantity;
  private String selectedProdLine,
           selectedBotoxPresentAmt,
           selectedBotoxPresentQty,
           selectedSalesOrderGroup
           ;
  private String[] selectedFillersProdNames,
           selectedDummyFillersProdNames;
  private SelectOption[] prodLineSelOpts,
               fillersProdNameSelOpts,
               botoxPresentAmtSelOpts,
               botoxPresentQtySelOpts,
               metricSelOpts = new SelectOption[] {
                        new SelectOption(MetricType.Quantity.name(),'Quantity'),
                        new SelectOption(MetricType.Amount.name(), 'Amount')
               },
               dataPresSelOpts = new SelectOption[] {
                        new SelectOption(DataPresType.MonthTotal.name(),'Total by month'),
                        new SelectOption(DataPresType.YearRollup.name(), 'Rolled up within year')
               },
               salesOrderGroupSelOpts = new SelectOption[] {
                            new SelectOption(anyValue, String.format('-- {0} --', new String[] { 'Any' })),
                            new SelectOption(salesSalesOrderGroup, 'Sales'),
                            new SelectOption(freegoodsSalesOrderGroup, 'Freegoods')
               };

  private ID[] allFillersProdIds;
  private Map<String, List<ID>> fillersProdNameIds;
  private MetricType selectedMetric = MetricType.Quantity;
  private DataPresType selectedDataPres = DataPresType.MonthTotal;
  private Account acc;
  public void ChangeMetric(){

      if(Metric=='Quantity'){
          selectedMetric=MetricType.Quantity;
      }else{
          selectedMetric=MetricType.Amount;
      }
      UpdateChartTable();
  }
  private final Account initAcc,
              inputAcc;
  private final Date refDate,
          lastDayCurMonth,
          firstDayCurYear,
          firstDayPrevYear,
          lastDayPrevYear,
          firstDayPrev2Year,
          lastDayPrev2Year;

  private SalesHistoryGraph[] chartSalesHistory;
  private SalesHistoryTable[] tableSalesHistory;
  private Map<Integer, SalesHistoryGraph> monthSalesHistGraph;
  private Map<Integer, SalesHistoryTable> yearSalesHistTable;

  private static String[] allBotoxProdDescs = new String[] { 'Botox 50 u',
                            'Botox 100 u',
                            'Botox 200 u'
              };
  private static String convBotoxProdDesc = FindConvertedBotoxProdDesc();
  private static SalesOrderGroup[] salesOrderGroups = new SalesOrderGroup[] {
                              new SalesOrderGroup(anyValue, new String[] { 'DEMAND', 'DEMAND-FREEGOODS', 'FREEGOODS', 'GRSALES', 'RETURNS', 'DISCOUNT','SAMPLES' }),
                              new SalesOrderGroup(salesSalesOrderGroup, new String[] { 'DEMAND', 'GRSALES', 'RETURNS', 'DISCOUNT' }),
                              new SalesOrderGroup(freegoodsSalesOrderGroup, new String[] { 'DEMAND-FREEGOODS', 'FREEGOODS','SAMPLES' })
  };

  private String valSelectedBU;
  public String SelectedBU
  {
    get { return valSelectedBU; }

    set { valSelectedBU= value; }
  }

  private Selectoption[] valListBU;
   public SelectOption[] ListBU
  {
    get { return valListBU; }
  }


  private String valSelectedTherapeuticArea;
  public String SelectedTherapeuticArea
  {
    get { return valSelectedTherapeuticArea; }

    set { valSelectedTherapeuticArea= value; }
  }

  private Selectoption[] valListTherapeuticArea;
   public SelectOption[] ListTherapeuticArea
  {
    get { return valListTherapeuticArea; }
  }



  private String valSelectedDetailGroup;
  public String SelectedDetailGroup
  {
    get { return valSelectedDetailGroup; }

    set { valSelectedDetailGroup= value; }
  }

  /* BugFix-R14.1 */
  public String SelectedDetailGroupDisp {
    get {
        System.debug('======== valSelectedDetailGroup NSM ======= '+valSelectedDetailGroup);
        if(valSelectedDetailGroup == null || valSelectedDetailGroup == '' || valSelectedDetailGroup == '0'){
            System.debug('========== Inside Selected Detail Group NSM ========= ');
            return null;
        }else{
            for(Product_vod__c prd_sel : allProducts) {
                if(prd_sel.id == valSelectedDetailGroup)
                    return prd_sel.Name;
            }
          return valSelectedDetailGroup;
      }        
    }
  }

  private Selectoption[] valListDetailGroup;
   public SelectOption[] ListDetailGroup
  {
    get { return valListDetailGroup; }
  }



  private String valSelectedDetail;
  public String SelectedDetail
  {
    get { return valSelectedDetail; }

    set { valSelectedDetail= value; }
  }

  /* BugFix-R14.1 */
   public String SelectedDetailDisp {
       get {
           System.debug('=========== valSelectedDetail NSM ========= '+valSelectedDetail);               
           if(valSelectedDetail == null || valSelectedDetail == '' || valSelectedDetail == '0'){
               System.debug('======= IN IF Condition NSM =======');
               return null;
           }else{           
               for(Product_vod__c prd_sel : allProducts) {        
                   if(prd_sel.id == valSelectedDetail)
                       return prd_sel.Name;
               }
               return valSelectedDetail;
           }                      
       }
   }

  private Selectoption[] valListDetail;
   public SelectOption[] ListDetail
  {
    get { return valListDetail; }
  }

   private String valSelectedListSubType;
  public String SelectedListSubType
  {
    get { return valSelectedListSubType; }

    set { valSelectedListSubType= value; }
  }

  /* BugFix-R14.1 */
   public String SelectedListSubTypeDisp {
    get {
          System.debug('============ valSelectedListSubType NSM ============== '+valSelectedListSubType);
            if(valSelectedListSubType == null || valSelectedListSubType == '' || valSelectedListSubType == '0'){
                System.debug('============ Inside Selected SubType NSM ============');
                return null;
            }else{
                for(Product_vod__c prd_sel : allProducts) {
                if(prd_sel.id == valSelectedListSubType)
                  return prd_sel.Name;
              }
    
              return valSelectedListSubType;
            }
        }        
   }
    
    

  private Selectoption[] valListSubType;
   public SelectOption[] ListSubType
  {
    get { return valListSubType; }
  }


  private Set<String> setBusinessUnits;
  private Set<String> setTherapeuticAreas;
  private List<Product_vod__c> lstProductDetailGroups;
  private List<Product_vod__c> lstProductDetails;
  private List<Product_vod__c> lstProductSamples;
  private List<Product_vod__c> lstProductOrders;

  private Map<String,Set<String>> mapBUToTherapeuticArea;
  private Map<String,List<String>> mapTherapeuticAreaToDG;
  private Map<String,List<String>> mapDetailGroupToDetail;
  private Map<String,List<String>> mapDetailToSample;
  private Map<String,List<String>> mapDetailToOrder;

  private String[] strProductIdsForQuery;


  // Enumeration definition
  //
  public enum MetricType {
    Quantity,
    Amount
  }

  public enum DataPresType {
    MonthTotal,
    YearRollup
  }

  // Class definition
  //
  private class SalesOrderGroup {
    public SalesOrderGroup(String parName, String[] parSalesOrderTypes)
    {
      name = parName;
      salesOrderTypes = parSalesOrderTypes;
    }

    public String name;
    public String[] salesOrderTypes;
  }

  public class SalesHistoryGraph {

    public SalesHistoryGraph(Integer month, Integer curYear)
    {
      this.month = month;

      monthName = getShortMonth(month);
      this.curYear = curYear;

      curYearQuantity = 0;
      curYearAmount = 0;
      prevYearQuantity = 0;
      prevYearAmount = 0;
      prev2YearQuantity = 0;
      prev2YearAmount = 0;

      curYearRollupQuantity = 0;
      prevYearRollupQuantity = 0;
      prev2YearRollupQuantity = 0;
      curYearRollupAmount = 0;
      prevYearRollupAmount = 0;
      prev2YearRollupAmount = 0;

      curYearRndRollupQuantity = 0;
      prevYearRndRollupQuantity = 0;
      prev2YearRndRollupQuantity = 0;
      curYearRndRollupAmount = 0;
      prevYearRndRollupAmount = 0;
      prev2YearRndRollupAmount = 0;
    }

    private void AddData(Integer year, Double quantity, Decimal amount)
    {
      // Values are rounded because the Visualforce Chart component truncates
      //  the decimal part of fraction numbers which cam lead to a rather
      //  confusing situation. For instance: 1.9 is treated as if it was 1
      //  (and not 2 as it would normally be expected)
      if (year == curYear)
      {
        curYearQuantity = Decimal.valueOf(quantity).round(System.RoundingMode.HALF_UP);
        curYearAmount = AGN_AccountSalesReportController.RoundAmount(amount);
      }
      else if (year == curYear - 1)
      {
        prevYearQuantity = Decimal.valueOf(quantity).round(System.RoundingMode.HALF_UP);
        prevYearAmount = AGN_AccountSalesReportController.RoundAmount(amount);
      }
      else if (year == curYear - 2)
      {
        prev2YearQuantity = Decimal.valueOf(quantity).round(System.RoundingMode.HALF_UP);
        prev2YearAmount = AGN_AccountSalesReportController.RoundAmount(amount);
      }
    }

    private void AddRollupData(Integer year, Double quantity, Decimal amount)
    {
      if(amount==null) amount=0;
      if (year == curYear)
      {
        curYearRollupQuantity += quantity;
        curYearRndRollupQuantity = Decimal.valueOf(curYearRollupQuantity).round(System.RoundingMode.HALF_UP);

        curYearRollupAmount += amount;
        curYearRndRollupAmount = AGN_AccountSalesReportController.RoundAmount(curYearRollupAmount);
      }
      else if (year == curYear - 1)
      {
        prevYearRollupQuantity += quantity;
        prevYearRndRollupQuantity = Decimal.valueOf(prevYearRollupQuantity).round(System.RoundingMode.HALF_UP);

        prevYearRollupAmount += amount;
        prevYearRndRollupAmount = AGN_AccountSalesReportController.RoundAmount(prevYearRollupAmount);
      }
      else if (year == curYear - 2)
      {
        prev2YearRollupQuantity += quantity;
        prev2YearRndRollupQuantity = Decimal.valueOf(prev2YearRollupQuantity).round(System.RoundingMode.HALF_UP);

        prev2YearRollupAmount += amount;
        prev2YearRndRollupAmount = AGN_AccountSalesReportController.RoundAmount(prev2YearRollupAmount);
      }
    }

    public Double curYearQuantity { get; private set; }
    public Double prevYearQuantity { get; private set; }
    public Double prev2YearQuantity { get; private set; }
    public Decimal curYearAmount { get; private set; }
    public Decimal prevYearAmount { get; private set; }
    public Decimal prev2YearAmount { get; private set; }
    public Double curYearRndRollupQuantity { get; private set; }
    public Double prevYearRndRollupQuantity { get; private set; }
    public Double prev2YearRndRollupQuantity { get; private set; }
    public Decimal curYearRndRollupAmount { get; private set; }
    public Decimal prevYearRndRollupAmount { get; private set; }
    public Decimal prev2YearRndRollupAmount { get; private set; }
    public String monthName { get; private set; }

    private Integer curYear,
            month;
    private Double curYearRollupQuantity,
             prevYearRollupQuantity,
             prev2YearRollupQuantity;
    private Decimal curYearRollupAmount,
             prevYearRollupAmount,
             prev2YearRollupAmount;


    Public String getShortMonth(Integer intMonth){
        String retVal='';

        if(intMonth==1){
             retVal='Jan';
        }
        if(intMonth==2){
             retVal='Feb';
        }
        if(intMonth==3){
             retVal='Mar';
        }
        if(intMonth==4){
             retVal='Apr';
        }
        if(intMonth==5){
             retVal='May';
        }
        if(intMonth==6){
             retVal='Jun';
        }
        if(intMonth==7){
             retVal='Jul';
        }
        if(intMonth==8){
             retVal='Aug';
        }
        if(intMonth==9){
             retVal='Sep';
        }
        if(intMonth==10){
             retVal='Oct';
        }
        if(intMonth==11){
             retVal='Nov';
        }
        if(intMonth==12){
             retVal='Dec';
        }

        return retVal;
    }
  }

  public class SalesHistoryTable {

    public SalesHistoryTable(Integer year, Integer curYear, Integer curMonth, String color, String currIsoCode)
    {
      this.year = year;
      this.curYear = curYear;
      this.curMonth = curMonth;
      this.color = color;
      monthSales = new SAP_Customer_Order_AGN__c[] {};
      monthYearRollupSales = new SAP_Customer_Order_AGN__c[] {};
      monthFrmtSalesQuantities = new String[] {};
      monthFrmtYearRollupSalesQuantities = new String[] {};

      for (Integer month = 1; month <= 12; month++)
      {
        monthSales.add(new SAP_Customer_Order_AGN__c(CurrencyIsoCode = currIsoCode));
        monthYearRollupSales.add(new SAP_Customer_Order_AGN__c(CurrencyIsoCode = currIsoCode));
        monthFrmtSalesQuantities.add('');
        monthFrmtYearRollupSalesQuantities.add('');
      }

      parcTotal = new SAP_Customer_Order_AGN__c(CurrencyIsoCode = currIsoCode);
      yearTotal = new SAP_Customer_Order_AGN__c(CurrencyIsoCode = currIsoCode);
    }

    private void AddData(Integer month, Double quantity, Decimal amount)
    {
      // Save month data
      SAP_Customer_Order_AGN__c opp = monthSales[month - 1];
      if(amount==null){amount=0;}
      opp.Quantity_AGN__c= quantity;
      opp.Net_Price_AGN__c= amount;

      for (Integer rollupMonthIdx = month - 1; rollupMonthIdx < (year == curYear ? curMonth : 12); rollupMonthIdx++)
      {
        SAP_Customer_Order_AGN__c rollupOpp = monthYearRollupSales[rollupMonthIdx];

        rollupOpp.Quantity_AGN__c= (rollupOpp.Quantity_AGN__c != null ? rollupOpp.Quantity_AGN__c : 0) + quantity;
        rollupOpp.Net_Price_AGN__c= (rollupOpp.Net_Price_AGN__c!= null ? rollupOpp.Net_Price_AGN__c: 0) + amount;
      }

      // Format quantity values to be displayed properly
      monthFrmtSalesQuantities[month - 1] = AGN_AccountSalesReportController.FormatQuantity(quantity);

      for (Integer rollupMonthIdx = month - 1; rollupMonthIdx < (year == curYear ? curMonth : 12); rollupMonthIdx++)
      {
        SAP_Customer_Order_AGN__c rollupOpp = monthYearRollupSales[rollupMonthIdx];

        if (rollupOpp.Quantity_AGN__c != null)
        {
          monthFrmtYearRollupSalesQuantities[rollupMonthIdx] = AGN_AccountSalesReportController.FormatQuantity((Double)rollupOpp.Quantity_AGN__c);
        }
      }

      if (month <= curMonth)
      {
        // A month not past the current month.
        //  Increment parcial total values
        parcTotal.Quantity_AGN__c= (parcTotal.Quantity_AGN__c!= null ? parcTotal.Quantity_AGN__c: 0) + quantity;
        parcTotal.Net_Price_AGN__c= (parcTotal.Net_Price_AGN__c != null ? parcTotal.Net_Price_AGN__c : 0) + amount;
      }

      // Increment year total values
      yearTotal.Quantity_AGN__c= (yearTotal.Quantity_AGN__c!= null ? yearTotal.Quantity_AGN__c : 0) + quantity;
      yearTotal.Net_Price_AGN__c = (yearTotal.Net_Price_AGN__c != null ? yearTotal.Net_Price_AGN__c : 0) + amount;
    }

    public SAP_Customer_Order_AGN__c[] monthSales { get; private set; }
    public SAP_Customer_Order_AGN__c[] monthYearRollupSales { get; private set; }
    public SAP_Customer_Order_AGN__c parcTotal { get; private set; }
    public SAP_Customer_Order_AGN__c yearTotal { get; private set; }
    public String color { get; private set; }
    public String[] monthFrmtSalesQuantities { get; private set; }
    public String[] monthFrmtYearRollupSalesQuantities { get; private set; }
    public YearVariation prevYearVariation { get; private set; }


    public String formattedParcTotalQuantity
    {
      get { return AGN_AccountSalesReportController.FormatQuantity((Double)parcTotal.Quantity_AGN__c); }
    }

    public String formattedYearTotalQuantity
    {
      get { return AGN_AccountSalesReportController.FormatQuantity((Double)yearTotal.Quantity_AGN__c); }
    }

    public String FormattedYear
    {
      get { return String.valueOf(year); }
    }

    private Integer year,
            curYear,
            curMonth;
  }

  public class YearVariation {

    public YearVariation(){

    }
    public YearVariation (AGN_AccountSalesReportController pgCtrl, Integer year)
    {
      Integer prevYear = year - 1;
      Decimal quantityYear = null,
          amountYear = null,
          quantityPrevYear = null,
          amountPrevYear = null;

      if (prevYear >= pgCtrl.refDate.year() - (pgCtrl.addPrev2Year ? 2 : 1))
      {
        SalesHistoryTable yearHistRec = pgCtrl.yearSalesHistTable.get(year),
                  prevYearHistRec = pgCtrl.yearSalesHistTable.get(prevYear);

        quantityYear = yearHistRec.parcTotal.Quantity_AGN__c;
        amountYear = yearHistRec.parcTotal.Net_Price_AGN__c;
        quantityPrevYear = prevYearHistRec.parcTotal.Quantity_AGN__c;
        amountPrevYear = prevYearHistRec.parcTotal.Net_Price_AGN__c;
      }

      quantityVar = AGN_AccountSalesReportController.CalcVariation(quantityYear, quantityPrevYear);
      amountVar = AGN_AccountSalesReportController.CalcVariation(amountYear, amountPrevYear);

      frmtQuantityVar = quantityVar != null ? quantityVar.format() + '%' : '-';
      frmtAmountVar = amountVar != null ? amountVar.format() + '%' : '-';
    }

    public String frmtQuantityVar { get; private set; }
    public String frmtAmountVar { get; private set; }

    private Decimal quantityVar,
            amountVar;
  }

  // Private static methods
  //
  private static String FindConvertedBotoxProdDesc()
  {
    String foundDesc = '';
    Pattern findPttrn = Pattern.compile('^.*(\\b|[^0-9])100(\\b|[^0-9]).*$');

    for (String botoxProdDesc : allBotoxProdDescs)
    {
      if (findPttrn.matcher(botoxProdDesc).matches())
      {
        foundDesc = botoxProdDesc;
      }
    }

    return foundDesc;
  }

  private MetricType ParseMetricType(String type)
  {
    MetricType resValue = null;

    for (MetricType value : MetricType.values())
    {
      if (value.name() == type)
        resValue = value;
    }

    return resValue;
  }

  private DataPresType ParseDataPresType(String type)
  {
    DataPresType resValue = null;

    for (dataPresType value : DataPresType.values())
    {
      if (value.name() == type)
        resValue = value;
    }

    return resValue;
  }

  private String GetOptionLabel(SelectOption[] selOpts, String value)
  {
    String label = null;

    for (SelectOption selOpt : selOpts)
    {
      if (selOpt.getValue() == value)
      {
        label = selOpt.getLabel();
        break;
      }
    }

    return label;
  }

  private String GetMultiSelectOptionLabels(SelectOption[] selOpts, String[] values)
  {
    String labels = null;

    for (String value : values)
    {
      for (SelectOption selOpt : selOpts)
        if (selOpt.getValue() == value)
        {
          if (labels == null)
            labels = selOpt.getLabel();
          else
            labels += ';' + selOpt.getLabel();

          break;
        }
    }

    return labels;
  }

  // Round decimal value preserving scale
  private static Decimal RoundAmount(Decimal amount)
  {
    if(amount!=null){
        Integer scale = amount.scale();
        return Decimal.valueOf(amount.round(System.RoundingMode.HALF_UP)).setScale(scale);
    }
    else return 0;
  }

  private static String FormatQuantity(Double quantity)
  {
    return quantity != null ? quantity.format() : null;
  }

  private static Decimal CalcVariation(Decimal yearVal, Decimal prevYearVal)
  {
    if (yearVal == null)
    {
      yearval = 0;
    }

    return prevYearVal != null && prevYearVal != 0 ? ((yearVal - prevYearVal) * 100).divide(prevYearVal, 0, System.RoundingMode.HALF_EVEN) : null;
  }

  // Constructor
  //
  public AGN_AccountSalesReportController(ApexPages.standardController stdController)
  {
    // Instantiate object to handle multi currencies
    dcmConversionRate=1;

    // Get reference date
    refDate = date.newinstance(Date.Today().year(), 12, 31);

    // Calculate and set bounding days of periods
    lastDayCurMonth = Date.newInstance(refDate.year(), refDate.month(), Date.daysInMonth(refDate.year(), refDate.month()));
    firstDayCurYear = Date.newInstance(refDate.year(), 1, 1);
    firstDayPrevYear = firstDayCurYear.addYears(-1);
    lastDayPrevYear = Date.newInstance(firstDayPrevYear.year(), 12, 31);
    firstDayPrev2Year = firstDayPrevYear.addYears(-1);
    lastDayPrev2Year = lastDayPrevYear.addYears(-1);

    // Initialize product variables
    InitProducts();

    // Obtain account
    //Account[] accs = [select Id, Name, ParentId, Parent.Name, Group_Principal_Account_Id__c, CurrencyIsoCode from Account where Id = :stdController.getId()];
    Account[] accs = [select Id, Name, ParentId, Parent.Name,  CurrencyIsoCode from Account where Id = :stdController.getId()];

    initAcc = acc = accs.size() > 0 ? accs[0] : null;

    inputAcc = new Account();

    print = false;

    if (acc != null)
    {
      // Retrieve sales data

        List<CurrencyType> lstCurrency=[SELECT Id, ConversionRate FROM CurrencyType WHERE IsoCode = :acc.CurrencyIsoCode];
        if(lstCurrency!=null && lstCurrency.size()>0){
            dcmConversionRate=lstCurrency[0].ConversionRate.setscale(5);
        }

      RetrieveSalesData();
    }
  }

  // Private methods
  //
  private void InitProducts()
  {
    // Prepare values for Prodct Line picklist field
    prodLineSelOpts = new SelectOption[] {};

    for (String prodLine : allProdLines)
    {
      prodLineSelOpts.add(new SelectOption(prodLine, prodLine == healthOrberaProdLine ? 'Health - Orbera/BIB' : prodLine));
    }

    selectedProdLine = allProdLines[0];

    // Prepare values for Botox Presentation picklist fields
    botoxPresentAmtSelOpts = new SelectOption[] {};
    botoxPresentQtySelOpts = new SelectOption[] {};

    botoxPresentAmtSelOpts.add(new SelectOption(anyValue, String.format('-- {0} --', new String[] { 'Any' })));
    botoxPresentQtySelOpts.add(new SelectOption(anyValue, String.format('-- {0} ({1}) --', new String[] { 'Any', 'unconverted' })));
    botoxPresentQtySelOpts.add(new SelectOption(convValue, String.format('-- {0} ({1}) --', new String[] { 'Converted', convBotoxProdDesc.replaceAll('^Botox +', '') })));

    for (String botoxProdDesc : allBotoxProdDescs)
    {
      botoxPresentAmtSelOpts.add(new SelectOption(botoxProdDesc, botoxProdDesc.replaceAll('^Botox +', '')));
      botoxPresentQtySelOpts.add(new SelectOption(botoxProdDesc, botoxProdDesc.replaceAll('^Botox +', '')));
    }

    selectedBotoxPresentAmt = anyValue;
    selectedBotoxPresentQty = convValue;
    selectedSalesOrderGroup = anyValue;

    // Prepare values for Fillers Product Name picklist field
    String lastProdName = null;

    fillersProdNameSelOpts = new SelectOption[] {};
    allFillersProdIds = new ID[] {};
    fillersProdNameIds = new Map<String, List<ID>>();

    for (Product_vod__c allProd : [select Id, Name from Product_vod__c order by Name asc])
    {
      if (allProd.Name!= lastProdName)
      {
        if (lastProdName == null)
        {
          // fillersProdNameSelOpts.add(new SelectOption(anyValue, '-- ' +'Any' + ' --'));
        }

        // fillersProdNameSelOpts.add(new SelectOption(allProd.Name, allProd.Name));
        // fillersProdNameIds.put(allProd.Name, new ID[] { allProd.Id });

        lastProdName = allProd.Name;
      }
      else
      {
        // fillersProdNameIds.get(lastProdName).add(allProd.Id);
      }

      // allFillersProdIds.add(allProd.Id);
    }

    if (fillersProdNameSelOpts.size() > 0)
    {
      selectedFillersProdNames = new String[] { anyValue };
      selectedDummyFillersProdNames = selectedFillersProdNames;
    }



        List<User> lstUsr= [SELECT Country_Code__c FROM User WHERE Id = : UserInfo.getUserId()];
        List<Product_vod__c> fullData =[select id,name,Product_Type_vod__c,Parent_Product_vod__c,Business_Unit_AGN__c,Therapeutic_Area_AGN__c   from Product_vod__c where (Product_Type_vod__c = 'Detail Group' or Product_Type_vod__c = 'Detail' or Product_Type_vod__c = 'Sample' or Product_Type_vod__c = 'Order') and Country_Code__c=:lstUsr[0].Country_Code__c ];
        valListDetailGroup=new SelectOption[] {}; //R010
        lstProductDetailGroups=new List<Product_vod__c>();
        lstProductDetails=new List<Product_vod__c>();
        lstProductSamples=new List<Product_vod__c>();
        lstProductOrders=new List<Product_vod__c>();
        valListDetailGroup.add(new SelectOption('0', '-- ' +'Any' + ' --')); //R010
        if(fullData !=null && fullData .size()>0){
            for(Product_vod__c currentObj : fullData ){
                if(currentObj.Product_Type_vod__c == 'Detail Group'){
                    lstProductDetailGroups.add(currentObj);
                }
                if(currentObj.Product_Type_vod__c == 'Detail'){
                    lstProductDetails.add(currentObj);
                }
                if(currentObj.Product_Type_vod__c == 'Sample'){
                    lstProductSamples.add(currentObj);
                }
                if(currentObj.Product_Type_vod__c == 'Order'){
                    lstProductOrders.add(currentObj);
                }
            }

        }

        valListBU=new SelectOption[] {};
        valListBU.add(new SelectOption('0', '-- ' +'Any' + ' --'));

        valListTherapeuticArea=new SelectOption[] {};
        valListTherapeuticArea.add(new SelectOption('0', '-- ' +'Any' + ' --'));

        valListDetail=new SelectOption[] {};
        valListDetail.add(new SelectOption('0', '-- ' +'Any' + ' --'));

        valListSubType=new SelectOption[] {};
        valListSubType.add(new SelectOption('0', '-- ' +'Any' + ' --'));

        List<Product_Group_vod__c> lstProductGroup =[select id,name,Product_Catalog_vod__c,Product_vod__r.Name,Product_vod__r.ID,Product_vod__c from Product_Group_vod__c];

        mapDetailGroupToDetail =new Map<String,List<String>>();
        mapBUToTherapeuticArea=new Map<String,Set<String>>();
        mapTherapeuticAreaToDG=new Map<String,List<String>>();
        List<String> tempList = new List<String>();
        Set<String> tempSet = new Set<String>();
        String currentDetailGroup='';
        setBusinessUnits=new Set<String>();
        setTherapeuticAreas=new Set<String>();
        if(lstProductDetailGroups !=null && lstProductDetailGroups.size()>0){
            for(Product_vod__c currentObj : lstProductDetailGroups){
                currentDetailGroup=currentObj.ID;
                 tempList = new List<String>();
                 setBusinessUnits.add(currentObj.Business_Unit_AGN__c);
                 setTherapeuticAreas.add(currentObj.Therapeutic_Area_AGN__c);
                 for(Product_Group_vod__c currentObjChild : lstProductGroup ){

                    if(currentObj.ID ==currentObjChild.Product_Catalog_vod__c){
                        tempList.add(currentObjChild.Product_vod__c+'~~~~'+currentObjChild.Product_vod__r.Name);
                    }

                }
                mapDetailGroupToDetail.put(String.valueof(currentDetailGroup),tempList);
            }
            for(String currentBU : setBusinessUnits){
                if(currentBU!=null && currentBU!=''){
                tempSet = new Set<String>();
                valListBU.add(new SelectOption(currentBU , currentBU ));
                for(Product_vod__c currentObj : lstProductDetailGroups){
                    if(currentBU == currentObj.Business_Unit_AGN__c){
                        tempSet.add(currentObj.Therapeutic_Area_AGN__c);
                    }
                }
                mapBUToTherapeuticArea.put(currentBU ,tempSet);
                }
            }

            for(String currentTA : setTherapeuticAreas){
                tempList = new List<String>();
                for(Product_vod__c currentObj : lstProductDetailGroups){
                    if(currentTA == currentObj.Therapeutic_Area_AGN__c){
                        tempList.add(currentObj.id+'~~~~'+currentObj.Name); //R010

                    }
                }
                mapTherapeuticAreaToDG.put(currentTA ,tempList );
            }




       }


       mapDetailToSample=new Map<String,List<String>>();
        if(lstProductDetails !=null && lstProductDetails.size()>0){
            for(Product_vod__c currentObj : lstProductDetails){
                currentDetailGroup=currentObj.ID;
                 tempList = new List<String>();
                for(Product_vod__c  currentObjChild : lstProductSamples){
                    if(currentObj.ID ==currentObjChild.Parent_Product_vod__c){
                        tempList.add(currentObjChild.ID+'~~~~'+currentObjChild.Name);
                    }
                }
                mapDetailToSample.put(String.valueof(currentDetailGroup),tempList);
            }
        }
        mapDetailToOrder=new Map<String,List<String>>();
        if(lstProductDetails !=null && lstProductDetails.size()>0){
            for(Product_vod__c currentObj : lstProductDetails){
                currentDetailGroup=currentObj.ID;
                 tempList = new List<String>();
                for(Product_vod__c  currentObjChild : lstProductOrders){
                    if(currentObj.ID ==currentObjChild.Parent_Product_vod__c){
                        tempList.add(currentObjChild.ID+'~~~~'+currentObjChild.Name);
                    }
                }
                mapDetailToOrder.put(String.valueof(currentDetailGroup),tempList);
            }
        }


  }

  public void ChangeBU(){


      String strId='';
      String strName='';
      valListTherapeuticArea.clear();
      valListTherapeuticArea.add(new SelectOption('0', '-- ' +'Any' + ' --'));
      valSelectedTherapeuticArea='0';
      //New R010
      valListDetailGroup.clear();
      valListDetailGroup.add(new SelectOption('0', '-- ' +'Any' + ' --'));
      valSelectedDetailGroup='0';
      //End
      valListDetail.clear();
      valListDetail.add(new SelectOption('0', '-- ' +'Any' + ' --'));
      valSelectedDetail='0';
      valListSubType.clear();
      valListSubType.add(new SelectOption('0', '-- ' +'Any' + ' --'));
      valSelectedListSubType='0';
        if(valSelectedBU!='0'){
            for(String currentObj : mapBUToTherapeuticArea.get(valSelectedBU)){
                if(currentObj !=null && currentObj !=''){

                    strName=currentObj;
                    valListTherapeuticArea.add(new SelectOption(strName, strName));

                }
                }

                getProductIds(valSelectedBU,'BU');
          }

      UpdateChartTable();
  }


  public void ChangeTherapeuticArea(){



      String strId='';
      String strName='';
      //New R010
      valListDetailGroup.clear();
      valListDetailGroup.add(new SelectOption('0', '-- ' +'Any' + ' --'));
      valSelectedDetailGroup='0';
      //End
      valListDetail.clear();
      valListDetail.add(new SelectOption('0', '-- ' +'Any' + ' --'));
      valSelectedDetail='0';
      valListSubType.clear();
      valListSubType.add(new SelectOption('0', '-- ' +'Any' + ' --'));
      valSelectedListSubType='0';
        if(valSelectedTherapeuticArea!='0'){
            for(String currentObj : mapTherapeuticAreaToDG.get(valSelectedTherapeuticArea)){
                if(currentObj !=null && currentObj !=''){
                    strId=currentObj.split('~~~~')[0];
                    strName=currentObj.split('~~~~')[1];

                    system.debug('DetailGroup list....'+strName+'..Id...' +strId);
                            valListDetailGroup.add(new SelectOption(strId, strName));
                        system.debug('valListDetailGroup '+valListDetailGroup);
                }
          }
          getProductIds(valSelectedTherapeuticArea,'TherapeuticArea');
      }
      UpdateChartTable();
  }



  // NEW - R010
  public void ChangeProductDetailGroups(){

      strProductIdsForQuery=new String[]{};
      String strId='';
      String strName='';
      valListDetail.clear();
      valListDetail.add(new SelectOption('0', '-- ' +'Any' + ' --'));
      valSelectedDetail='0';
      valListSubType.clear();
      valListSubType.add(new SelectOption('0', '-- ' +'Any' + ' --'));
      valSelectedListSubType='0';
        if(valSelectedDetailGroup!='0'){
            for(String currentObj : mapDetailGroupToDetail.get(ID.valueof(valSelectedDetailGroup))){
                if(currentObj !=null && currentObj !=''){
                    strId=currentObj.split('~~~~')[0];
                    strName=currentObj.split('~~~~')[1];
                    valListDetail.add(new SelectOption(strId, strName));
                    }
                }

             getProductIds(valSelectedDetailGroup,'DetailGroup');
          }

      UpdateChartTable();
  }
  // END


  public void ChangeProductDetail(){

      strProductIdsForQuery=new String[]{};
      String strId='';
      String strName='';
      valListSubType.clear();
      valListSubType.add(new SelectOption('0', '-- ' +'Any' + ' --'));
      valSelectedListSubType='0';
      System.debug('========= valSelectedDetail Before IF ====== NSM =========== '+valSelectedDetail);
        if(valSelectedDetail!='0'){
            System.debug('========= valSelectedDetail Inside IF ====== NSM =========== '+valSelectedDetail);
            System.debug('============== mapDetailToSample ============= NSM ======= '+mapDetailToSample);            
           // System.debug('============= mapDetailToSample Key Size ========== NSM ======== '+ mapDetailToSample.get(ID.valueof(valSelectedDetail)).size());
           // System.debug('============= mapDetailToSample Key Value ========== NSM ======== '+mapDetailToSample.get(ID.valueof(valSelectedDetail)));
            
            if(mapDetailToSample.get(ID.valueof(valSelectedDetail)) != null){                
                for(String currentObj : mapDetailToSample.get(ID.valueof(valSelectedDetail))){
                    System.debug('========= currentObj ====== NSM =========== '+currentObj);
                    if(currentObj !=null && currentObj !='' && currentObj != '0'){
                        strId=currentObj.split('~~~~')[0];
                        strName=currentObj.split('~~~~')[1];
                        valListSubType.add(new SelectOption(strId, strName +'  [Sample]'));
                        strProductIdsForQuery.add(strId);
                        }
                    }
                 for(String currentObj : mapDetailToOrder.get(ID.valueof(valSelectedDetail))){
                    if(currentObj !=null && currentObj !=''){
                        strId=currentObj.split('~~~~')[0];
                        strName=currentObj.split('~~~~')[1];
                        valListSubType.add(new SelectOption(strId, strName +'  [Order]'));
                        strProductIdsForQuery.add(strId);
                        }
                    }
              }
             getProductIds(valSelectedDetail,'DetailProduct');
          }

      UpdateChartTable();
  }

  public void ChangeSubtype(){


      getProductIds(valSelectedListSubType,'ProductSubtype');

      UpdateChartTable();
  }

  private void getProductIds(String currentValue,String CurrentLevel){
      strProductIdsForQuery=new String[]{};
      String[] arrThArea=new String[]{};
      String[] arrDetailGroupProduct=new String[]{};
      String[] arrDetailProduct=new String[]{};

      String strId='';
      String strName='';
      Boolean LevelFlag=false;
      if(CurrentLevel=='BU'){

          for(String currentObj : mapBUToTherapeuticArea.get(currentValue)){
                    if(currentObj !=null && currentObj !=''){

                        strName=currentObj;
                        arrThArea.add(strName);

                    }
          }
          CurrentLevel='TherapeuticArea';
          LevelFlag=true;
      }
      if(CurrentLevel=='TherapeuticArea'){
              if(currentValue =='0'){
                  arrThArea.clear();
                  for(SelectOption obj : ListTherapeuticArea){
                      arrThArea.add(obj.getValue());
                  }
              }
              else if(!LevelFlag){
                  if(currentValue!=null && currentValue!=''){
                      arrThArea.clear();
                      arrThArea.add(currentValue);
              }
          }
          for(String currentObj : arrThArea){
              for(String currentChildObj : mapTherapeuticAreaToDG.get(currentObj)){
                    if(currentChildObj  !=null && currentChildObj !=''){

                        strId=currentChildObj.split('~~~~')[0] ;
                        arrDetailGroupProduct.add(strId);

                    }
              }
          }
          //R010
          for(String currentObj : arrDetailGroupProduct){
              for(String currentChildObj : mapDetailGroupToDetail.get(ID.valueof(currentObj))){
                    if(currentChildObj  !=null && currentChildObj !=''){

                        strId=currentChildObj.split('~~~~')[0];
                        arrDetailProduct.add(strId);

                    }
              }
          }
          CurrentLevel='DetailGroup';
          LevelFlag=true;
      }


      //New R010
       if(CurrentLevel=='DetailGroup'){
              if(currentValue =='0'){
                  arrDetailGroupProduct.clear();
                  for(SelectOption obj : ListDetailGroup){
                      arrDetailGroupProduct.add(obj.getValue());
                  }
              }
              else if(!LevelFlag){
                  if(currentValue!=null && currentValue!=''){
                      arrDetailGroupProduct.clear();
                      arrDetailGroupProduct.add(currentValue);
              }
          }

          for(String currentObj : arrDetailGroupProduct){
              for(String currentChildObj : mapDetailGroupToDetail.get(ID.valueof(currentObj))){
                    if(currentChildObj  !=null && currentChildObj !=''){

                        strId=currentChildObj.split('~~~~')[0];
                        arrDetailProduct.add(strId);

                    }
              }
          }
          CurrentLevel='DetailProduct';
          LevelFlag=true;
      }

      //End

      if(CurrentLevel=='DetailProduct'){
          if(!LevelFlag){
              if(currentValue =='0'){
                  arrDetailProduct.clear();
                  for(SelectOption obj : ListDetail){
                      arrDetailProduct.add(obj.getValue());
                  }
              }
              else if(currentValue!=null && currentValue!=''){
                  arrDetailProduct.clear();
                  arrDetailProduct.add(currentValue);
              }
          }
          String subtypeid='';
          for(String currentObj : arrDetailProduct){
              strId=currentObj.split('~~~~')[0];
              if(mapDetailToSample.containskey(ID.valueof(strId))){
              for(String currentChildObj : mapDetailToSample.get(ID.valueof(strId))){
                    if(currentChildObj  !=null && currentChildObj !=''){

                        subtypeid=currentChildObj .split('~~~~')[0];
                        strProductIdsForQuery.add(subtypeid);

                    }
              }
              for(String currentChildObj : mapDetailToOrder.get(ID.valueof(strId))){
                    if(currentChildObj  !=null && currentChildObj !=''){

                        subtypeid=currentChildObj  .split('~~~~')[0];
                        strProductIdsForQuery.add(subtypeid);

                    }
              }
              }
          }
          LevelFlag=true;
      }
      if(CurrentLevel=='ProductSubtype'){
          if(!LevelFlag){
              if(currentValue =='0'){
                  strProductIdsForQuery.clear();
                  for(SelectOption obj : valListSubType){
                      strProductIdsForQuery.add(obj.getValue());
                  }
              }
              else if(currentValue!=null && currentValue!=''){
                  strProductIdsForQuery.clear();
                  strProductIdsForQuery.add(currentValue);
              }
          }
      }


  }

  private void RetrieveSalesData()
  {
    allProducts = [Select Id, Name, Product_Type_vod__c from Product_vod__c]; 
    System.debug('====== Product_vod__c ========== '+allProducts);
    List<User> lstUsr= [SELECT Country_Code__c FROM User WHERE Id = : UserInfo.getUserId()];
    String strCountryCode=lstUsr[0].Country_Code__c;
    maxQuantity = 0;
    chartSalesHistory = new SalesHistoryGraph[] {};
    tableSalesHistory = new SalesHistoryTable[] {};
    monthSalesHistGraph = new Map<Integer, SalesHistoryGraph>();
    yearSalesHistTable = new Map<Integer, SalesHistoryTable>();
    Date initialDate = addPrev2Year ? firstDayPrev2Year : firstDayPrevYear;
    Integer lastYear = 0,
        lastMonth = 0,
        colorIdx = addPrev2Year ? yearColors.size() - 1 : yearColors.size() - 2;

    for (Date dt = initialDate; dt <= lastDayCurMonth; dt = dt.addMonths(1))
    {
      Integer year = dt.year(),
          month = dt.month();

      if (year != lastYear)
      {
        // A new year
        SalesHistoryTable tableData = new SalesHistoryTable(year, refDate.year(), refDate.month(), yearColors[colorIdx--], acc.CurrencyIsoCode);

        tableSalesHistory.add(tableData);
        yearSalesHistTable.put(year, tableData);

        lastYear = year;
      }

      if (lastMonth < 12)
      {
        // A new month
        SalesHistoryGraph chartData = new SalesHistoryGraph(month, refDate.year());

        chartSalesHistory.add(chartData);
        monthSalesHistGraph.put(month, chartData);

        lastMonth = month;
      }
    }

    // Prepare to requery sales records
    //
    ID accId = acc.Id;

    String prAccId = '',
         selectedBotoxPresent = BotoxPresentation;
    String[] salesOrderTypes = GetSalesOrderTypes(),
         prodLineNames = GetProdLineNames();
    ID[] fillersProdIds = GetFillersProdIds();
    //String accWhereClause = (IsPrincipalAccount && !prAccOnly) || (!IsPrincipalAccount && prAccRollup) ? 'Account.Group_Principal_Account_Id__c = :prAccId' : 'AccountId = :accId',
    String[] arrAccounts=new String[]{};
    if(IsPrincipalAccount && !prAccOnly){
        for(Account objAccount : [select ID from account where ParentId=:accId ]){
            arrAccounts.add(objAccount .id);
        }
    }

    if(!IsPrincipalAccount && prAccRollup){


        for(Account objAccount : [select ID from account where ParentId=: acc.ParentId]){
            arrAccounts.add(objAccount .id);
        }
        arrAccounts.add(acc.ParentId);

    }
    arrAccounts.add(accId);

    String accWhereClause =  'Account_AGN__c in :arrAccounts',
    ProductIdClause=strProductIdsForQuery==null ? '' : strProductIdsForQuery.size()!=0 ? ' and Material_AGN__c in: strProductIdsForQuery' : '' ,
         //prodWhereClause = selectedProdLine == fillersProdLine ? 'Product__c in :fillersProdIds' : (selectedProdLine == botoxProdLine && BotoxPresentation != anyValue && BotoxPresentation != convValue ? 'Product__r.Product_Description__c = :selectedBotoxPresent' : 'Product__r.Product_Line__c in :prodLineNames'),
         //prodWhereClause = selectedProdLine == fillersProdLine ? 'Product__c in :fillersProdIds' : (selectedProdLine == botoxProdLine && BotoxPresentation != anyValue && BotoxPresentation != convValue ? 'Product__r.Product_Description__c = :selectedBotoxPresent' : 'Product__r.Product_Line__c in :prodLineNames'),
         qtyFieldName = selectedProdLine == botoxProdLine && BotoxPresentation == convValue ? 'Quantity_AGN__c' : 'Quantity_AGN__c',


         soqlStmt = 'select Calendar_Year(Invoice_Date_AGN__c) Year, Calendar_Month(Invoice_Date_AGN__c) Month, Sum(Net_Price_AGN__c) TotalAmount, Sum(' + qtyFieldName + ') TotalQuantity,Sum(Sales_Amount_AGN__c) from SAP_Customer_Order_AGN__c where ' + accWhereClause + +ProductIdClause+ ' and Invoice_Date_AGN__c>= :initialDate and Invoice_Date_AGN__c<= :lastDayCurMonth and REASON_DES_AGN__c in :salesOrderTypes and Country_Code_AGN__c =:strCountryCode group by Calendar_Year(Invoice_Date_AGN__c), Calendar_Month(Invoice_Date_AGN__c) order by Calendar_Year(Invoice_Date_AGN__c) desc, Calendar_Month(Invoice_Date_AGN__c) asc';
         //soqlStmt = 'select Calendar_Year(Invoice_Date_AGN__c) Year, Calendar_Month(Invoice_Date_AGN__c) Month, Sum(Net_Price_AGN__c) TotalAmount, Sum(' + qtyFieldName + ') TotalQuantity from SAP_Customer_Order_AGN__c where ' + accWhereClause + ' and Invoice_Date_AGN__c>= :initialDate and Invoice_Date_AGN__c<= :lastDayCurMonth group by Calendar_Year(Invoice_Date_AGN__c), Calendar_Month(Invoice_Date_AGN__c) order by Calendar_Year(Invoice_Date_AGN__c) desc, Calendar_Month(Invoice_Date_AGN__c) asc';

    // Retrieve sales records and load history data


    for (AggregateResult agResult : Database.query(soqlStmt))
    {
      Integer year = (Integer)agResult.get('Year'),
          month = (Integer)agResult.get('Month');
      Double quantity = (Double)agResult.get('TotalQuantity');
      Decimal amount = (Decimal)agResult.get('TotalAmount')*dcmConversionRate;

      monthSalesHistGraph.get(month).AddData(year, quantity, amount);

      // Accumulate values to rollup fields from current month to
      //  last month (up to the reference date) of current year
      for (Integer rollupMonth = month; rollupMonth <= (year == refDate.year() ? refDate.month() : 12); rollupMonth++)
      {
        monthSalesHistGraph.get(rollupMonth).AddRollupData(year, quantity, amount);
      }

      yearSalesHistTable.get(year).AddData(month, quantity, amount);

      if ((year >= refDate.year() - 1 || addPrev2Year) && quantity > maxQuantity)
      {
        maxQuantity = quantity;
      }
    }

    // Set previous years variations
    for (Integer year = refDate.year() - (addPrev2Year ? 2 : 1); year <= refDate.year() ; year++)
    {
      yearSalesHistTable.get(year).prevYearVariation = new YearVariation(this, year);
    }
  }

  private String[] GetSalesOrderTypes()
  {
    String[] salesOrderTypes = null;

    for (SalesOrderGroup soGroup : salesOrderGroups)
    {
      if (soGroup.name == selectedSalesOrderGroup)
      {
        salesOrderTypes = soGroup.salesOrderTypes;
        break;
      }
    }

    return salesOrderTypes != null ? salesOrderTypes : new String[] {};
  }

  private Boolean IsFillersProdSelected(String prodName)
  {
    Boolean isSelected = false;

    for (String fillersProdName : selectedFillersProdNames)
      if (fillersProdName == prodName)
      {
        isSelected = true;
        break;
      }

    return isSelected;
  }

  private ID[] GetFillersProdIds()
  {
    ID[] ids = null;

    if (selectedProdLine == fillersProdLine)
    {
      if (IsFillersProdSelected(anyValue))
        ids = allFillersProdIds;
      else
      {
        ids = new ID[] {};

        for (String fillersProdName : selectedFillersProdNames)
        {
          ids.addAll(fillersProdNameIds.get(fillersProdName));
        }
      }
    }

    return ids != null ? ids : new ID[] {};
  }

  private String[] GetProdLineNames()
  {
    String[] prodLineNames = new String[] { selectedProdLine };

    if (selectedProdLIne == healthOrberaProdLine)
    {
      prodLineNames.add('Health - BIB');
    }

    return prodLineNames;
  }

    // Private properties
    //
  private Double MaxRndRollupQuantity
  {
      get
      {
          Double maxValue = chartSalesHistory[refDate.month() - 1].curYearRndRollupQuantity;

          if (chartSalesHistory[11].prevYearRndRollupQuantity > maxValue)
          {
              maxValue = chartSalesHistory[11].prevYearRndRollupQuantity;
          }

          return addPrev2Year && chartSalesHistory[11].prev2YearRndRollupQuantity > maxValue ? chartSalesHistory[11].prev2YearRndRollupQuantity : maxValue;
      }
  }

  // Public propperties
  //
  public Boolean IsGenericAccount
  {
    get { return initAcc == null; }
  }

  public Boolean HasAccount
  {
    get { return acc != null; }
  }

  public Account InputAccount
  {
    get { return inputAcc; }
  }

  public Account Account
  {
    get { return acc; }
  }

  public Boolean IsPrincipalAccount
  {
    get { return acc != null ? (acc.ParentId == null ? true : false) : null; }
  }

  public String PrincipalAccountName
  {
    get { return acc != null ? (acc.ParentId != null ? acc.Parent.Name : acc.Name) : null; }
  }

  public Boolean PrincipalAccRollup
  {
    get { return prAccRollup; }

    set { prAccRollup = value; }
  }

  public Boolean PrincipalAccountOnly
  {
    get { return prAccOnly; }

    set { prAccOnly = value; }
  }

  public Boolean IsRollupDataPresentation
  {
    get { return selectedDataPres == dataPresType.YearRollup; }
  }

  public SelectOption[] ProductLineSelOptions
  {
    get { return prodLineSelOpts; }
  }

  public String ProductLine
  {
    get { return selectedProdLine; }

    set { selectedProdLine = value; }
  }

  public SelectOption[] SalesOrderGroupSelOptions
  {
    get { return salesOrderGroupSelOpts; }
  }

  public String SalesOrderGroup
  {
    get { return selectedSalesOrderGroup; }

    set { selectedSalesOrderGroup = value; }
  }

  public SelectOption[] BotoxPresentationAmountSelOptions
  {
    get { return botoxPresentAmtSelOpts; }
  }

  public String BotoxPresentationAmount
  {
    get { return selectedBotoxPresentAmt; }

    set { selectedBotoxPresentAmt = value; }
  }

  public Boolean ShowBotoxPresentationAmount
  {
    get { return selectedMetric != MetricType.Quantity; }
  }

  public SelectOption[] BotoxPresentationQuantitySelOptions
  {
    get { return botoxPresentQtySelOpts; }
  }

  public String BotoxPresentationQuantity
  {
    get { return selectedBotoxPresentQty; }

    set { selectedBotoxPresentQty = value; }
  }

  public Boolean ShowBotoxPresentationQuantity
  {
    get { return selectedMetric == MetricType.Quantity; }
  }

  public String BotoxPresentation
  {
    get { return selectedMetric == MetricType.Quantity ? selectedBotoxPresentQty : selectedBotoxPresentAmt; }
  }

  public Boolean ShowBotoxPresentation
  {
    get { return selectedProdLine == botoxProdLine; }
  }

  public SelectOption[] FillersProductNameSelOptions
  {
    get { return fillersProdNameSelOpts; }
  }

  public Integer FillersProductNameSelOptionsSize
  {
    get { return fillersProdNameSelOpts.size() > cnMaxFillersProdNameSelOptionsSize ? cnMaxFillersProdNameSelOptionsSize : fillersProdNameSelOpts.size(); }
  }

  public String[] FillersProductNames
  {
    get { return selectedFillersProdNames; }

    set { selectedDummyFillersProdNames = selectedFillersProdNames = value; }
  }

  public String[] DummyFillersProductNames
  {
    get { return selectedFillersProdNames; }

    set { }
  }

  public Boolean ShowFillersProductName
  {
    get { return selectedProdLine == fillersProdLine; }
  }

  public SelectOption[] MetricSelOptions
  {
    get { return metricSelOpts; }
  }

  public String Metric
  {
    get { return selectedMetric.name(); }

    set { selectedMetric = ParseMetricType(value); }
  }

  public SelectOption[] DataPresentationSelOptions
  {
    get { return dataPresSelOpts; }
  }

  public String DataPresentation
  {
    get { return selectedDataPres.name(); }

    set { selectedDataPres = ParseDataPresType(value); }
  }

  public Boolean AddPrevious2Year
  {
    get { return addPrev2Year; }

    set { addPrev2Year = value; }
  }

  public SalesHistoryGraph[] ChartData
  {
    get { return chartSalesHistory; }
  }

  public Integer CurrentYear
  {
    get { return refDate.year(); }
  }

  public String[] GraphLineColors
  {
    get { return yearColors; }
  }

  public String GraphBarColors
  {
    get
    {
      String colors = '';

      for (Integer idx = addPrev2Year ? yearColors.size() - 1 : yearColors.size() - 2; idx >= 0; idx--)
      {
        if (colors.length() > 0)
        {
          colors += ',';
        }

        colors += yearColors[idx];
      }

      return colors;
    }
  }

  public String GraphBarLegends
  {
    get
    {
      String legends = '';

      for (Date dt = addPrev2Year ? firstDayPrev2Year : firstDayPrevYear; dt <= firstDayCurYear; dt = dt.addYears(1))
      {
        if (legends.length() > 0)
        {
            legends += ',';
        }

        legends += String.valueOf(dt.year());
      }

      return legends;
    }
  }

  public String GraphYAxisTitle
  {
    get { return acc != null ? (selectedMetric == MetricType.Quantity ? 'Quantity' : ('Amount' + ' (' + acc.CurrencyIsoCode + ')')) : null; }
  }

  public Double GraphYAxisMaximum
  {
    get
    {
      Double maximum = null;

      if (selectedMetric == MetricType.Quantity)
      {
        Double rndMaxQuantity = IsRollupDataPresentation ? MaxRndRollupQuantity : Decimal.valueOf(maxQuantity).round(System.RoundingMode.HALF_UP);
        Integer step = rndMaxQuantity > 0 ? ((rndMaxQuantity - 1) / cnMaxYAxisSteps).intValue() + 1 : 1;

        maximum = rndMaxQuantity > 0 ? Math.ceil(rndMaxQuantity / step) * step : 1;
      }

      return maximum;
    }
  }

  public Integer GraphYAxisSteps
  {
    get
    {
      Integer numSteps = null;

      if (selectedMetric == MetricType.Quantity)
      {
        Double rndMaxQuantity = IsRollupDataPresentation ? MaxRndRollupQuantity : Decimal.valueOf(maxQuantity).round(System.RoundingMode.HALF_UP);
        Integer step = rndMaxQuantity > 0 ? ((rndMaxQuantity - 1) / cnMaxYAxisSteps).intValue() + 1 : 1,
                maximum = rndMaxQuantity > 0 ? Math.ceil(rndMaxQuantity / step).intValue() * step : 1;

        numSteps = maximum > 1 ? (maximum / step) - 1 : 1;
      }

      return numSteps;
    }
  }

  public String GraphBarFields
  {
    get
    {
      String fields = selectedMetric == MetricType.Quantity ? 'prevYearQuantity,curYearQuantity' : 'prevYearAmount,curYearAmount';

      if (addPrev2Year)
      {
        fields = (selectedMetric == MetricType.Quantity ? 'prev2YearQuantity,' : 'prev2YearAmount,') + fields;
      }

      return fields;
    }
  }

  public String GraphLineFields
  {
    get
    {
      String fields = selectedMetric == MetricType.Quantity ? 'curYearRndRollupQuantity,prevYearRndRollupQuantity' : 'curYearRndRollupAmount,prevYearRndRollupAmount';

      if (addPrev2Year)
      {
        fields += selectedMetric == MetricType.Quantity ? ',prev2YearRndRollupQuantity' : ',prev2YearRndRollupAmount';
      }

      return fields;
    }
  }

  public String[] GraphRollupFields
  {
    get { return selectedMetric == MetricType.Quantity ? new String[] { 'curYearRndRollupQuantity', 'prevYearRndRollupQuantity', 'prev2YearRndRollupQuantity' } : new String[] { 'curYearRndRollupAmount', 'prevYearRndRollupAmount', 'prev2YearRndRollupAmount' }; }
  }

  public SalesHistoryTable[] TableData
  {
    get { return tableSalesHistory; }
  }

  public String[] MonthNames
  {
    get
    {
      String[] names = new String[] {};

      for (Integer month = 1; month <= 12; month++)
      {
        names.add(getShortMonth(month).capitalize());
      }

      return names;
    }
  }

  public String ParcialTotalMonthRange
  {
    get { return getShortMonth(1) + (refDate.month() > 1 ? '-' + getShortMonth(refDate.month()) : ''); }
  }

  public Boolean PrintPage
  {
    get { return print; }
  }

  public String MetricValue
  {
    get { return GetOptionLabel(metricSelOpts, Metric); }
  }

  public String SalesOrderGroupValue
  {
    get { return GetOptionLabel(salesOrderGroupSelOpts, selectedSalesOrderGroup); }
  }

  public String DataPresentationValue
  {
    get { return GetOptionLabel(dataPresSelOpts, DataPresentation); }
  }

  public String ProductLineValue
  {
    get { return GetOptionLabel(prodLineSelOpts, selectedProdLine); }
  }

  public String BotoxPresentationValue
  {
    get { return selectedMetric == MetricType.Quantity ?  GetOptionLabel(botoxPresentQtySelOpts, selectedBotoxPresentQty) : GetOptionLabel(botoxPresentAmtSelOpts, selectedBotoxPresentAmt); }
  }

  public String FillersProductNameValue
  {
    get { return GetMultiSelectOptionLabels(fillersProdNameSelOpts, selectedFillersProdNames); }
  }

  // Public methods
  //
  public PageReference UpdateChartTable()
  {
    print = false;

    RetrieveSalesData();

    return null;
  }

  public PageReference ChangeAccount()
  {
    print = false;

    // Try to retrieve newly selected account
    Account[] accs = [select Id, Name, ParentId, Parent.Name, CurrencyIsoCode from Account where Id = :inputAcc.ParentId];

    acc = accs.size() > 0 ? accs[0] : null;

    if (acc != null)
    {
      // Retrieve sales data
      RetrieveSalesData();
    }

    return null;
  }


  public PageReference DoPrint()
  {
    print = true;

    RetrieveSalesData();

    return null;
  }


    Public String getShortMonth(Integer intMonth){
        String retVal='';

        if(intMonth==1){
             retVal='Jan';
        }
        if(intMonth==2){
             retVal='Feb';
        }
        if(intMonth==3){
             retVal='Mar';
        }
        if(intMonth==4){
             retVal='Apr';
        }
        if(intMonth==5){
             retVal='May';
        }
        if(intMonth==6){
             retVal='Jun';
        }
        if(intMonth==7){
             retVal='Jul';
        }
        if(intMonth==8){
             retVal='Aug';
        }
        if(intMonth==9){
             retVal='Sep';
        }
        if(intMonth==10){
             retVal='Oct';
        }
        if(intMonth==11){
             retVal='Nov';
        }
        if(intMonth==12){
             retVal='dec';
        }

        return retVal;
    }
}