package com.sypay.omp.report.service.impl;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import scala.annotation.meta.getter;

import com.alibaba.fastjson.JSON;
import com.sypay.omp.per.model.page.DataGrid;
import com.sypay.omp.per.model.page.PageHelper;
import com.sypay.omp.report.VO.ChartVO;
import com.sypay.omp.report.VO.ConditionVO;
import com.sypay.omp.report.VO.PublicVO;
import com.sypay.omp.report.dao.BaseDao;
import com.sypay.omp.report.domain.ReportChart;
import com.sypay.omp.report.domain.ReportCondition;
import com.sypay.omp.report.domain.ReportElement;
import com.sypay.omp.report.domain.ReportPublic;
import com.sypay.omp.report.queryrule.Condition;
import com.sypay.omp.report.service.ReportPublicService;
import com.sypay.omp.report.util.StringUtil;

/**
 * 
 * @author lishun
 *
 * @2015年5月7日
 */
@Service(value="reportPublicService")
@Transactional
public class ReportPublicServiceImpl implements ReportPublicService {

    protected final Log log = LogFactory.getLog(ReportPublicServiceImpl.class);
    
    @Autowired
    private BaseDao baseDao;

    
    @Override
    public void saveReportPublic(ReportPublic reportPublic) {
        baseDao.save(reportPublic);
    }

    @Override
    public void updateReportPublic(ReportPublic reportPublic) {
        baseDao.update(reportPublic);
    }

    @Override
    public ReportPublic queryReportPublic(String reportFlag) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("toolFlag", reportFlag);
        return (ReportPublic) baseDao.get("from ReportPublic where toolFlag = :toolFlag", params);
    }

    /**
     * 保存报表公共信息，条件，图等
     * @param reportElement
     */
	@Override
	public void saveReport(ReportElement reportElement) {
		/* 公共信息 */
        ReportPublic reportPublic = new ReportPublic();
        reportPublic.setToolCColumn(reportElement.getSaveReportCColumn());
        reportPublic.setToolTitle(reportElement.getSaveReportTitle());
        reportPublic.setToolEColumn(reportElement.getSaveReportEColumn());
        reportPublic.setToolFlag(reportElement.getSaveReportFlag());
        reportPublic.setToolGather(reportElement.getSaveReportToolGather());
        reportPublic.setToolFormat(reportElement.getSaveReportFormatDatas());
        reportPublic = updateSql(reportPublic, reportElement.getSaveReportSqlId());//{"时":"2000","日":"2001","周":"2001","月":"2001"}
        baseDao.save(reportPublic);
        /* 存条件 */
        List<Condition> conList = JSON.parseArray(reportElement.getSaveReportCondition(), Condition.class);
        for (Condition con : conList) {
            ReportCondition reportCondition = new ReportCondition();
            reportCondition.setConMuti(con.getConValue());
            reportCondition.setConName(con.getName());
            reportCondition.setConOption(con.getOption());
            reportCondition.setConType(con.getType());
            reportCondition.setConWhere(con.getWhere());
            reportCondition.setToolFlag(reportElement.getSaveReportFlag());
            reportCondition.setOrderNum(con.getOrderNum());
            reportCondition.setRowNum(con.getRowNum());
            reportCondition.setConDefaultValue(con.getConDefaultValue());
            //reportCondition.setChartId("");
            baseDao.save(reportCondition);
        }
        
        /* 存图 */
        List<ChartVO> chartList = JSON.parseArray(reportElement.getSaveReportChart(), ChartVO.class);
        if (reportElement.getSaveChartFlag()) {
        	for (ChartVO chart : chartList) {
        		ReportChart reportChart = new ReportChart();
                reportChart.setChartName(chart.getChartName());
                reportChart.setChartOption(chart.getChartOption());
                reportChart.setChartOrder(chart.getChartOrder());
                reportChart.setChartType(chart.getChartType());
                reportChart.setDataVsLe(chart.getDataVsLe());
                reportChart.setDataVsX(chart.getDataVsX());
                reportChart.setToolFlag(reportElement.getSaveReportFlag());
                baseDao.save(reportChart);
        	}
        }
	}
	
	public ReportPublic updateSql(ReportPublic reportPublic , String originalStr) {
        /* String originalStr = "{\"时\":\"2000\",\"日\":\"2001\",\"周\":\"2001\",\"月\":\"2001\"}"; */
        originalStr = originalStr.substring(1, originalStr.length()-1);
        String [] strs = originalStr.split(","); //["时":"2000","时":"2000","时":"2000"]
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("\"时\"", "setToolHSqlId");
        map.put("\"日\"", "setToolDSqlId");
        map.put("\"周\"", "setToolWSqlId");
        map.put("\"月\"", "setToolMSqlId");
        map.put("\"季\"", "setToolQSqlId");
        map.put("\"年\"", "setToolYSqlId");
        Class<?> r = ReportPublic.class;
        for (String str : strs) {
        	String[] s = str.split(":");
        	Method m;
			try {
				m = r.getMethod(map.get(s[0]).toString() , String.class);
				m.invoke(reportPublic, s[1].replace("\"", ""));
			} catch (NoSuchMethodException e) {
				log.info("reflect exception : {}" + e);
			} catch (SecurityException e) {
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				e.printStackTrace();
			} catch (IllegalArgumentException e) {
				e.printStackTrace();
			} catch (InvocationTargetException e) {
				e.printStackTrace();
			}
        }
        return reportPublic;
    }

	/**
	 * 查找公共信息列表
	 */
	@Override
	public DataGrid findPublicList(PublicVO publicVo, PageHelper pageHelper) {
		DataGrid dataGrid = new DataGrid();
		String sql = "select id \"id\", toolccolumn \"toolCColumn\", tooldsqlid \"toolDSqlId\", toolecolumn \"toolEColumn\", toolflag \"toolFlag\", toolhsqlid \"toolHSqlId\", toolmsqlid \"toolMSqlId\", tooltitle \"toolTitle\", toolwsqlid \"toolWSqlId\" , toolqsqlid \"toolQSqlId\", toolysqlid \"toolYSqlId\", gather_column \"toolGather\", format \"toolFormat\" from rptpub where 1=1 "+ constructSqlWhere(publicVo)
				+ " order by 1 desc" ;
		Query query = baseDao.getSqlQuery(sql).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).setFirstResult((pageHelper.getPage() - 1) * pageHelper.getRows()).setMaxResults(pageHelper.getRows());;
		Map<String, Object> params = new HashMap<String, Object>();
        
        if (StringUtil.isNotEmpty(publicVo.getToolFlag())) {
        	query.setParameter("toolflag", publicVo.getToolFlag());
        	params.put("toolflag", publicVo.getToolFlag());
        }
        if (publicVo.getId() != null) {
        	query.setParameter("id", publicVo.getId());
        	params.put("id", publicVo.getId());
        }
        if (StringUtil.isNotEmpty(publicVo.getToolTitle())) {
        	query.setParameter("tooltitle", "%" + publicVo.getToolTitle() + "%");
        	params.put("tooltitle", "%" + publicVo.getToolTitle() + "%");
        }
		
		List<ReportPublic> list = (List<ReportPublic>)query.list();
		dataGrid.setRows(list);
		String countSql = "select count(1) from rptpub where 1=1" + constructSqlWhere(publicVo);
		dataGrid.setTotal((long)baseDao.countBySql(countSql, params));
		return dataGrid;
	}

	/**
	 * 组装条件
	 * @param publicVo
	 * @return
	 */
	private String constructSqlWhere(PublicVO publicVo) {
		String str = "";
		if (StringUtil.isNotEmpty(publicVo.getToolFlag())) {
			str = str + " and toolflag = :toolflag";
		}
		if (publicVo.getId() != null) {
			str = str + " and id = :id";
		}
		if (StringUtil.isNotEmpty(publicVo.getToolTitle())) {
			str = str + " and tooltitle like :tooltitle";
		}
		return str;
	}
	/**
	 * 更新公共信息
	 */
	@Override
	public void updatePublic(ReportPublic reportpublic) {
		baseDao.update(reportpublic);
	}
}
