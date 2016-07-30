package com.sypay.omp.report.web;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.sypay.omp.per.common.Constants;
import com.sypay.omp.per.common.ResultCodeConstants;
import com.sypay.omp.per.model.page.AjaxJson;
import com.sypay.omp.per.model.page.DataGrid;
import com.sypay.omp.per.model.page.PageHelper;
import com.sypay.omp.per.web.UserLoginController;
import com.sypay.omp.report.VO.ConditionVO;
import com.sypay.omp.report.domain.ReportCondition;
import com.sypay.omp.report.service.ReportConditionService;
import com.sypay.omp.report.util.BeanUtil;

/**
 * 图形管理
 * @author lishun
 *
 */
@Controller
@RequestMapping("/condition")
public class ReportConditionController {

	 private final Log logger = LogFactory.getLog(ReportConditionController.class);
	 
	 @Resource
	 private ReportConditionService reportConditionService;
	 /**
     * 跳转到资源列表页面
     * 
     * @return
     */
    @RequestMapping(value = "/condition.htm")
    public String resource() {
        return "condition/conditionList";
    }
    
    @RequestMapping(value = "/findConditionList.htm")
    @ResponseBody
    public DataGrid findConditionList(ConditionVO condition, PageHelper pageHelper) {
    	return reportConditionService.findConditionList(condition, pageHelper);
    }
    
    @RequestMapping(value = "/updateCondition.htm")
    @ResponseBody
    public AjaxJson updateCondition(ConditionVO condition, HttpServletRequest request) {
        AjaxJson json = new AjaxJson();
        if (condition.getId() == null || StringUtils.isBlank(condition.getToolFlag()) || StringUtils.isEmpty(condition.getConName())) {
        	json.setErrorNo(ResultCodeConstants.RESULT_INCOMPLETE);
            return json;
        }
        ReportCondition reportCondition = new ReportCondition();
        BeanUtil.copyProperties(condition, reportCondition);
        try {
        	reportConditionService.updateReportCondition(reportCondition);
		} catch (Exception e) {
	            json.setStatus(Constants.OpStatus.FAIL);
	            json.setErrorInfo("更新失败！");
	            return json;
		}
        return json;
    }
}
