/******************************************************************************
 *
 *               Confidentiality Information:
 *
 * This module is the confidential and proprietary information of
 * Veeva Systems, Inc.; it is not to be copied, reproduced, or transmitted
 * in any form, by any means, in whole or in part, nor is it to be used
 * for any purpose other than that for which it is expressly provided
 * without the written permission of Veeva Systems, Inc.
 *
 * Copyright (c) 2021 Veeva Systems, Inc.  All Rights Reserved.
 *
 *******************************************************************************/

/**
 * VeevaEmBusRuleExpense Controller for expense rules.
 *
 */
@RestResource(urlMapping='/veeva/business-rule-expenses')
global without sharing class VeevaEmBusRuleExpense{
    
    @HttpPost
    global static VeevaEmExpenseRuleService.ExpenseResult processExpenseRules() {        
        VeevaEmExpenseRuleService.ExpenseResult expenseResult = new VeevaEmExpenseRuleService.ExpenseResult();
        RestResponse res = RestContext.response;
        Blob requestBody = RestContext.request.requestBody;
        if (requestBody != null) {
            String requestBodyStr = requestBody.toString();               
            VeevaEmExpenseRuleService service = new VeevaEmExpenseRuleService();  
            expenseResult = service.processExpenseRules(requestBodyStr);
        } else {
            expenseResult.success = false;
            expenseResult.errorMessage = 'Request body is null';
            res.statusCode = 400;
        }
        return expenseResult;
    }
}