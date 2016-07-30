package com.sypay.omp.report.VO;

/**
 * 
 * @author lishun
 *
 */
public class ReportSqlVO {
	private Long sqlId;
	private String baseSql;
	private String baseCountSql;
	private String rptname;

	public Long getSqlId() {
		return this.sqlId;
	}

	public void setSqlId(Long sqlId) {
		this.sqlId = sqlId;
	}

	public String getBaseSql() {
		return baseSql;
	}

	public void setBaseSql(String baseSql) {
		this.baseSql = baseSql;
	}

	public String getBaseCountSql() {
		return baseCountSql;
	}

	public void setBaseCountSql(String baseCountSql) {
		this.baseCountSql = baseCountSql;
	}

	public void setRptname(String rptname) {
		this.rptname = rptname;
	}

	public String getRptname() {
		return rptname;
	}
}
