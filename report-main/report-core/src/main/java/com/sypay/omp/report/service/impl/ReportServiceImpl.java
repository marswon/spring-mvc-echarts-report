package com.sypay.omp.report.service.impl;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.util.CellRangeAddress;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.sypay.omp.report.dao.ReportDao;
import com.sypay.omp.report.queryrule.PagerReq;
import com.sypay.omp.report.queryrule.PagerRsp;
import com.sypay.omp.report.service.ReportService;
import com.sypay.omp.report.util.StringUtil;

/**
 * 
 * @author lishun
 *
 */
@Service(value = "reportService")
@Transactional
public class ReportServiceImpl implements ReportService {

    protected final Log log = LogFactory.getLog(getClass());

    private ReportDao reportDao;

    @Autowired
    public void ReportServiceImpl(ReportDao reportDao) {
        this.reportDao = reportDao;
    }

    /**
	 * 导出报表
	 * @param paras
	 * @return
	 * @throws Exception
	 */
    public XSSFWorkbook smartReportExport(PagerReq paras) throws Exception {
        paras = setupSmartReportSql(paras);
        paras = updatePagerReq(paras);
        String title = paras.getTitle();
        String[] excelHeader = {};
        if (StringUtil.isNotEmpty(title)) {
            excelHeader = title.split(",");
        }

        XSSFWorkbook wb = new XSSFWorkbook();
        XSSFSheet sheet = wb.createSheet("Campaign");
        
        
        XSSFCellStyle style = wb.createCellStyle();
        style.setAlignment(HSSFCellStyle.ALIGN_CENTER);
        
        CellStyle headerStyle = getCellStyle(wb);
        boolean flag = false;
        /* 二级表头处理  e.g 日期,二级表头1:{金额|笔数},呵呵,二级表头2:{a|b|c}*/
        List<String> hbrow = new ArrayList<String>();
		List<Integer> hbcol = new ArrayList<Integer>();
		List<String> oneHeader = new ArrayList<String>();
		List<String> twoHeader = new ArrayList<String>();
		List<String> header = Arrays.asList(excelHeader);
		int hbnum = 0;
		for (int i=0; i<header.size(); i++) {
			String tmpString = header.get(i);
			if (tmpString.indexOf(":") != -1) {
				flag = true;
				/* 添加到twoHeader中的column */
				String[] tmpStr1 = tmpString.substring(tmpString.indexOf("{")+1,tmpString.indexOf("}")).split("\\|");
				hbrow.add(hbnum + "-" + (tmpStr1.length+hbnum-1));
				oneHeader.add(tmpString.substring(0 , tmpString.indexOf(":")));
				for (int j=0; j<tmpStr1.length-1; j++) {
					oneHeader.add("");
				}
				twoHeader.addAll(Arrays.asList(tmpStr1));
				hbnum = hbnum + tmpStr1.length;
			} else {
				hbcol.add(hbnum);
				oneHeader.add(tmpString);
				twoHeader.add("");
				hbnum++;	
			}
		}
        
        /* 创建标题第一行 */
		int dataIndex = 1;
		XSSFRow row = null;
        
        /* 创建标题第二行 */
        if (flag) {
        	dataIndex = 2;
        	row = sheet.createRow((int) 0);
            for (int i = 0; i < oneHeader.size(); i++) {
                XSSFCell cell = row.createCell(i);
                cell.setCellValue(oneHeader.get(i));
                cell.setCellStyle(headerStyle);
                sheet.autoSizeColumn(i);
            }
            
        	XSSFRow row1 = sheet.createRow((int) 1);
            for (int i = 0; i < twoHeader.size(); i++) {
                XSSFCell cell = row1.createCell(i);
                cell.setCellValue(twoHeader.get(i));
                cell.setCellStyle(headerStyle);
                sheet.autoSizeColumn(i);
            }
            /* 合并列 */
            for (int i=0; i<hbcol.size(); i++) {
            	sheet.addMergedRegion(new CellRangeAddress(0, 1, hbcol.get(i), hbcol.get(i)));
            }
            /* 合并行 */
            for (int i=0; i<hbrow.size(); i++) {
            	String[] rowRange = hbrow.get(i).split("-");
            	sheet.addMergedRegion(new CellRangeAddress(0, 0, Integer.valueOf(rowRange[0]), Integer.valueOf(rowRange[1])));
            }
        } else {
        	row = sheet.createRow((int) 0);
            for (int i = 0; i < excelHeader.length; i++) {
                XSSFCell cell = row.createCell(i);
                cell.setCellValue(excelHeader[i]);
                cell.setCellStyle(headerStyle);
                sheet.autoSizeColumn(i);
            }
        }
        expReportQueryData(paras, dataIndex, row, sheet);
        return wb;
    }
    
    /**
     * 根据条件获取数据的入口
     * 
     * @param PagerReq
     *            req
     * @return PagerRsp
     */
    @Transactional(readOnly = true)
    public PagerRsp getReportData(PagerReq req) {
        PagerRsp rsp = new PagerRsp();
        // 取QID模式
        reportDao.setupReportSql(req);
        rsp.setRows(reportDao.getData(req));
        if (StringUtils.isEmpty(req.getBaseCountSql())) {
            int records = rsp.getRows() == null ? 0 : rsp.getRows().size();
            rsp.setRecords(records);
        } else {
            rsp.setRecords(reportDao.getDataCount(req));
        }
        if (req.getRows() > 0) {
            rsp.setTotal((int) Math.ceil((double) rsp.getRecords()
                    / req.getRows()));
        } else {
            rsp.setTotal(0);
        }
        return rsp;
    }

    public PagerReq setupSmartReportSql(PagerReq req) {
        return reportDao.setupSmartReportSql(req);
    }

    public List createReportQueryData(PagerReq req) {
        return reportDao.createReportQueryData(req);
    }

    @Override
    public List showReportQueryData(PagerReq req) {
        return reportDao.showReportQueryData(req);
    }

    /**
     * 导出数据，用scroll执行，否则大量分页数据会有重复
     * @param dataIndex 行数
     * @param row HSSFRow
     * @param sheet HSSFSheet
     * @param req PagerReq
     */
    @Override
	public void expReportQueryData(PagerReq req, int dataIndex, XSSFRow row, XSSFSheet sheet) {
		reportDao.expReportQueryData(req, dataIndex, row, sheet);
	}
    
    @Override
    public Integer showReportQueryDataCount(PagerReq req) {
        return reportDao.showReportQueryDataCount(req);
    }

    @Override
    public String getConValue(String sql) {
        StringBuffer conValue = new StringBuffer();
        List list = reportDao.getConValue(sql);
        for (Object str : list) {
            conValue.append(str.toString()).append(",");
        }
        String rtnStr = conValue.substring(0, conValue.length() - 1);
        return rtnStr;
    }

    @Override
    public PagerReq updatePagerReq(PagerReq req) {
        return reportDao.updatePagerReq(req);
    }
    
    /** 
     *  
     * @Title: getCellStyle 
     * @Description: TODO（设置表头样式） 
     * @param wb 
     * @return 
     */  
    public static CellStyle getCellStyle(Workbook wb){  
        CellStyle style = wb.createCellStyle();  
        Font font = wb.createFont();  
        font.setFontName("宋体");  
        font.setFontHeightInPoints((short)12);//设置字体大小  
        font.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);//加粗  
        style.setFillForegroundColor(HSSFColor.LIME.index);// 设置背景色  
        style.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);  
        style.setAlignment(HSSFCellStyle.SOLID_FOREGROUND);//让单元格居中  
        style.setAlignment(HSSFCellStyle.ALIGN_CENTER);
        style.setBorderTop(CellStyle.BORDER_THIN);
        style.setBorderLeft(CellStyle.BORDER_THIN);
        style.setBorderRight(CellStyle.BORDER_THIN);
        style.setBorderBottom(CellStyle.BORDER_THIN);
        //style.setWrapText(true);//设置自动换行  
        style.setFont(font);  
        return style;  
    }
}
