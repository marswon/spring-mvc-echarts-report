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
import com.sypay.omp.report.VO.ReportCommonConVO;
import com.sypay.omp.report.domain.ReportCommonCon;
import com.sypay.omp.report.service.ReportCommonConService;
import com.sypay.omp.report.util.BeanUtil;

/**
 * 共用报表差异条件管理
 * 
 * @author lishun
 *
 */
@Controller
@RequestMapping("/commonCondition")
public class ReportCommonConController {

	private final Log logger = LogFactory.getLog(ReportCommonConController.class);

	@Resource
	private ReportCommonConService reportCommonConService;

	/**
	 * 跳转到资源列表页面
	 * 
	 * @return
	 */
	@RequestMapping(value = "/commonCondition.htm")
	public String resource() {
		return "commonCondition/commonCondition";
	}
	/**
	 * 根据条件查找 
	 * @param reportCommonCon
	 * @param pageHelper
	 * @return
	 */
	@RequestMapping(value = "/findCommonConditionList.htm")
	@ResponseBody
	public DataGrid findCommonConditionList(ReportCommonConVO reportCommonCon, PageHelper pageHelper) {
		return reportCommonConService.findReportCommonConList(reportCommonCon, pageHelper);
	}

	/**
	 * 增加
	 * @param reportCommonConVO
	 * @param request
	 * @return
	 */
	@RequestMapping(value = "/addCommonCondition.htm")
	@ResponseBody
	public AjaxJson addCommonCondition(ReportCommonConVO reportCommonConVO, HttpServletRequest request) {
		AjaxJson json = new AjaxJson();
		if (StringUtils.isBlank(reportCommonConVO.getToolFlag())
				|| StringUtils.isEmpty(reportCommonConVO.getConFlag())) {
			json.setErrorNo(ResultCodeConstants.RESULT_INCOMPLETE);
			return json;
		}
		ReportCommonCon reportCommonCon = new ReportCommonCon();
		BeanUtil.copyProperties(reportCommonConVO, reportCommonCon);
		reportCommonConService.saveReportCommonCon(reportCommonCon);
		return json;
	}
	
	/**
	 * 修改
	 * @param reportCommonConVO
	 * @param request
	 * @return
	 */
	@RequestMapping(value = "/updateCommonCondition.htm")
	@ResponseBody
	public AjaxJson updateCommonCondition(ReportCommonConVO reportCommonConVO, HttpServletRequest request) {
		AjaxJson json = new AjaxJson();
		if (reportCommonConVO.getId() == null || StringUtils.isBlank(reportCommonConVO.getToolFlag())
				|| StringUtils.isEmpty(reportCommonConVO.getConFlag())) {
			json.setErrorNo(ResultCodeConstants.RESULT_INCOMPLETE);
			return json;
		}
		ReportCommonCon reportCommonCon = new ReportCommonCon();
		BeanUtil.copyProperties(reportCommonConVO, reportCommonCon);
		try {
			reportCommonConService.updateReportCondition(reportCommonCon);
		} catch (Exception e) {
			json.setStatus(Constants.OpStatus.FAIL);
			json.setErrorInfo("更新失败！");
			return json;
		}
		
		return json;
	}
}
