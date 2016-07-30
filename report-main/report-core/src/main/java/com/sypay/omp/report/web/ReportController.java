package com.sypay.omp.report.web;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.sypay.omp.per.domain.Member;
import com.sypay.omp.per.exception.UserNotFoundException;
import com.sypay.omp.per.util.SessionUtil;
import com.sypay.omp.report.VO.ReturnCondition;
import com.sypay.omp.report.domain.ReportChart;
import com.sypay.omp.report.domain.ReportCommonCon;
import com.sypay.omp.report.domain.ReportCondition;
import com.sypay.omp.report.domain.ReportElement;
import com.sypay.omp.report.domain.ReportPublic;
import com.sypay.omp.report.domain.ReportSql;
import com.sypay.omp.report.json.JsonResult;
import com.sypay.omp.report.queryrule.PagerReq;
import com.sypay.omp.report.queryrule.PagerRsp;
import com.sypay.omp.report.service.ReportChartService;
import com.sypay.omp.report.service.ReportCommonConService;
import com.sypay.omp.report.service.ReportConditionService;
import com.sypay.omp.report.service.ReportPublicService;
import com.sypay.omp.report.service.ReportService;
import com.sypay.omp.report.service.ReportSqlService;
import com.sypay.omp.report.statuscode.GlobalResultStatus;
import com.sypay.omp.report.util.BeanUtil;
import com.sypay.omp.report.util.StringUtil;
import com.sypay.omp.report.util.TimeUtil;

/**
 * 报表入口
 * @author lishun
 *
 */
@Controller
@RequestMapping("/report")
public class ReportController {
	
    private final  Logger log = LoggerFactory.getLogger(ReportController.class);
    
    /*  querylog中专门存放跟报表访问和导出相关的log，可以从该log中分析出报表使用的频率和异常 */
    private final  Logger querylog = LoggerFactory.getLogger("reportQuery");
    
    @Autowired
    ReportService reportService;

    @Autowired
    private ReportChartService reportChartService;
    
    @Autowired
    private ReportPublicService reportPublicService;
    
    @Autowired
    private ReportConditionService reportConditionService;
    
    @Autowired
    private ReportSqlService reportSqlService;
    
    @Autowired
    private ReportCommonConService reportCommonConService;
    
    /**
     * 正常报表展示时拉取数据
     * @param PagerReq paras
     * @return Object
     * @throws Exception 
     */
    @RequestMapping(value = "report")
    @ResponseBody
    public Object report(PagerReq paras) {
    	Member member = SessionUtil.getLoginInfo();
    	PagerRsp response = null;
    	querylog.info("report memberId:{} memberName:{} sqlId:{} condition:{}", member.getId(), member.getName(), paras.getQid(), paras.getFilters());
    	try {
    		response = reportService.getReportData(paras);
		} catch  (Exception e) {
			response.setPage(1);
			response.setRecords(0);
			response.setTotal(0);
			response.setRows(null);
			querylog.info("report Object2String memberId:{} memberName:{} sqlId:{} condition:{} exception:{}", member.getId(), member.getName(), paras.getQid(), paras.getFilters(), e.toString());
		}
    	return JsonResult.reportSuccess(response, TimeUtil.DATE_FORMAT_2);
    }
    
    /**
     * smartReport展示时拉取数据
     * @param Model
     * @param PagerReq
     * @return Object
     * @throws UserNotFoundException 
     */
    @RequestMapping(value="reportShowQueryData")
    @ResponseBody
    public Object reportShowQueryData(PagerReq req) {
    	Member member = SessionUtil.getLoginInfo();
    	querylog.info("reportShowQueryData   memberId:{} memberName:{} sqlId:{} condition:{}", member.getId(), member.getName(), req.getQid(), req.getCondition());
    	PagerRsp response = new PagerRsp();
    	try {
        	req = reportService.setupSmartReportSql(req);
            req = reportService.updatePagerReq(req);
            List list = reportService.showReportQueryData(req);
            response.setPage(req.getPage());
            if (list.size() == 0) {
            	response.setRows(null);
            } else
            	response.setRows(list);
            response.setRecords(reportService.showReportQueryDataCount(req));
            if (response.getRecords() == 0) {
            	response.setTotal(0);
            } else 
            	response.setTotal((int)Math.ceil((double)response.getRecords() / req.getRows()));
		} catch (Exception e) {
			if (e.getCause() == null) {
				querylog.info("reportShowQueryData  memberId:{} memberName:{} sqlId:{} condition:{} exception:{}", member.getId(), member.getName(), req.getQid(), req.getCondition(), e.getMessage());
			} else {
				querylog.info("reportShowQueryData  memberId:{} memberName:{} sqlId:{} condition:{} exception:{}", member.getId(), member.getName(), req.getQid(), req.getCondition(), e.getCause().toString());
			}
			throw e;
		}
    	return JsonResult.reportSuccess(response, TimeUtil.DATE_FORMAT_2);
    }
    
    /**
     * smartReport创建报表时拉取数据
     * @param model
     * @param req
     * @return
     */
    @RequestMapping(value="reportMakeQueryData")
    @ResponseBody
    public Object reportMakeQueryData(PagerReq req) {
    	Member member = SessionUtil.getLoginInfo();
    	log.info("reportMakeQueryData   memberId:{} memberName:{} sqlId:{} condition:{}", member.getId(), member.getName(), req.getQid(), req.getCondition());
    	PagerRsp response = new PagerRsp();
    	try {
    		List list = reportService.createReportQueryData(req);
            response.setPage(1);
            response.setRows(list);
            response.setRecords(list.size());
            response.setTotal(1);
		} catch (Exception e) {
			if (e.getCause() != null) {
				log.info("reportMakeQueryData memberId:{} memberName:{} sqlId:{} condition:{} exception {}", member.getId(), member.getName(), req.getQid(), req.getCondition(), e.getCause().toString());
				return JsonResult.fail(GlobalResultStatus.PARAM_ERROR, e.getCause().toString());
			} else {
				log.info("reportMakeQueryData memberId:{} memberName:{} sqlId:{} condition:{} exception {}", member.getId(), member.getName(), req.getQid(), req.getCondition(), e.getMessage());
				return JsonResult.fail(GlobalResultStatus.PARAM_ERROR, e.getMessage());
			}
		}
        
        return JsonResult.reportSuccess(response, TimeUtil.DATE_FORMAT_2);
    }
    
    /**
     * smartReport将reportFlag相关的图，条件，公共信息返回到页面拼装报表
     * @param model
     * @param reportFlag
     * @return
     */
    @RequestMapping(value="queryAll")
    @ResponseBody
    public Object queryAll(String reportFlag, String conFlag) {
    	Map<String, Object> map = new HashMap<String, Object>();
    	try {
    		List<ReturnCondition> returnConList = new ArrayList<ReturnCondition>();
    		List<ReportCondition> reportConditionList = reportConditionService.queryReportCondition(reportFlag);
			List<ReportCommonCon> commonConList = reportCommonConService.findReportCommonConList(reportFlag, conFlag);
			for (int i=0;i<reportConditionList.size();i++) {
				ReportCondition rptCondition = reportConditionList.get(i);
				ReturnCondition returnCon = new ReturnCondition();
				BeanUtil.copyProperties(rptCondition, returnCon);
				returnCon.setDisplay("Y");
				returnCon.setValue("");
				for (int j=0;j<commonConList.size();j++) {
					ReportCommonCon rptComCon = commonConList.get(j);
					if (rptCondition.getConWhere().equals(rptComCon.getConWhere())) {
						returnCon.setDisplay("N");
						returnCon.setValue(rptComCon.getConValue());
						break;
					}
				}
				returnConList.add(returnCon);
			}
    		ReportPublic reportPublic = reportPublicService.queryReportPublic(reportFlag);
            List<ReportChart> reportChartList = reportChartService.queryReportChart(reportFlag);
            
            map.put("reportPublic", reportPublic);
            map.put("reportChartList", reportChartList);
            map.put("reportConditionList", returnConList);
		} catch (Exception e) {
			log.info("queryAll {} exception {}", reportFlag, e.toString());
		}
        return JsonResult.success(map);
    }
    
    /**
     * smartReport创建报表时保存 公共信息、条件、图
     * @param model
     * @param reportElement
     * @return
     */
    @RequestMapping(value="saveReport")
    @ResponseBody
    public Object saveReport(ReportElement reportElement) {
    	if (StringUtils.isEmpty(reportElement.getSaveReportCColumn()) || StringUtil.isEmpty(reportElement.getSaveReportEColumn()) ||
    			StringUtil.isEmpty(reportElement.getSaveReportCondition()) || StringUtil.isEmpty(reportElement.getSaveReportSqlId()) ||
    			StringUtil.isEmpty(reportElement.getSaveReportTitle())) {
    		log.info("saveReport  缺少参数");
    		return JsonResult.fail(GlobalResultStatus.PARAM_MISSING);
    	}
    	ReportPublic reportPublic = reportPublicService.queryReportPublic(reportElement.getSaveReportFlag());
    	if (reportPublic != null) {
    		log.info("saveReport  报表已存在");
    		return JsonResult.fail(GlobalResultStatus.REPORT_EXIST);
    	}
        
        try {
        	/* 经测试，异常会回滚，三个对象必须都没问题才能存入 */
        	reportPublicService.saveReport(reportElement);
		} catch (Exception e) {
			log.info("saveReport  未知错误");
			return JsonResult.fail(GlobalResultStatus.UNKNOWN_FAIL);
		}
        
        return JsonResult.success();
    }


    /**
     * smartReport创建报表时根据baseSql生成baseCountSql并保存
     * @param baseSql
     * @param timeSelect
     * @param sqlIds
     * @param sqlName
     * @return
     */
    @RequestMapping(value="saveReportSql")
    @ResponseBody
    public Object saveReportSql(@RequestParam String baseSql, @RequestParam String timeSelect, @RequestParam String sqlIds,
    		@RequestParam String sqlName) {
    	if (StringUtil.isEmpty(baseSql) || StringUtil.isEmpty(timeSelect) || StringUtil.isEmpty(sqlName)) {
    		log.info("saveReportSql  缺少参数");
    		return JsonResult.fail(GlobalResultStatus.PARAM_MISSING);
    	}
    	
    	if (baseSql.indexOf("select") == -1 || baseSql.indexOf("from") == -1) {
    		log.info("saveReportSql  参数错误");
    		return JsonResult.fail(GlobalResultStatus.PARAM_ERROR);
    	}
    	
        Long sqlId = null;
        /* 根据sqlIds判断是否已经插入过。没有就新增， 有了就更新 */
        if (sqlIds.indexOf(timeSelect) == -1) {
            sqlId = reportSqlService.saveReportSql(baseSql,sqlName);
            log.info("saveReportSql rp_report_sql表中没有存在，返回插入的sql_id");
        } else {
        	/* "月":"1026" */ 
            String str = sqlIds.substring(sqlIds.indexOf(timeSelect)+4);
            sqlId = Long.valueOf(str.substring(0, str.indexOf("\"")));
            ReportSql reportSql = reportSqlService.findReportSqlById(sqlId);
            if (null != reportSql) {
                String baseCountSql = reportSqlService.getCountSQL(baseSql);
                reportSql.setBaseSql(baseSql);
                reportSql.setBaseCountSql(baseCountSql);
                reportSql.setRptname(sqlName);
                reportSqlService.updateReportSql(reportSql);
            }
            log.info("saveReportSql rp_report_sql表中已存在，更新表并返回sql_id");
        }
        
        /* 返回新增/更新的sqlid */
        return JsonResult.success(sqlId);
    }
    
    /**
     * smartReport展示报表获取动态条件(为select或者checkBox时)
     * @param selectSql
     * @return String
     */
    @RequestMapping(value="getConValue")
    @ResponseBody
    public Object getConValue(@RequestParam String selectSql) {
    	if (StringUtil.isEmpty(selectSql)) {
    		log.info("getConValue  缺少参数");
    		return JsonResult.fail(GlobalResultStatus.PARAM_MISSING);
    	}
    	String conValue = "";
    	try {
    		conValue = reportService.getConValue(selectSql);
    		log.info("getConValue    selectSql: {} result: {}", selectSql, conValue);
		} catch (Exception e) {
			log.info("getConValue    selectSql: {} exception: {}", selectSql, e.toString());
		}
        return JsonResult.success(conValue);
    }
}
