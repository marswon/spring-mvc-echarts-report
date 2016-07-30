package com.sypay.omp.report.util;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Enumeration;
import java.util.Properties;

import org.springframework.web.multipart.MultipartFile;

import com.sypay.omp.per.util.PropertyReader;
import com.sypay.omp.report.util.excelUtils.ExcelReaderUtil;
import com.sypay.omp.report.util.excelUtils.IRowReader;
import com.sypay.omp.report.util.excelUtils.JDBCRowReader;

/**
 * 日志批量插入数据库工具类
 * 
 * @author lishun
 *
 */
public class JDBCUtils {
	/* JDBC驱动和数据库信息 */
	private String DB_DRIVER;
	private String DB_CONNECTION;
	private String DB_USER;
	private String DB_PASSWORD;

	/* 运营EXCEL导入一 */
	private final int importExcelNum = 1;

	public Connection dbConnection = null;
	public PreparedStatement preparedStatement = null;
	
	public void doFirst ()  throws FileNotFoundException, IOException{
		Properties properties = new Properties();
		properties.load(JDBCUtils.class.getClassLoader().getResourceAsStream("/data-access.properties"));
		Enumeration enum1 = properties.propertyNames();// 得到配置文件的名字
		while (enum1.hasMoreElements()) {
			String strKey = (String) enum1.nextElement();
			String strValue = properties.getProperty(strKey);
			System.out.println(strKey + "=" + strValue);
		}
		DB_DRIVER = properties.getProperty("jdbc_driverClassName");
		DB_CONNECTION = properties.getProperty("jdbc_url");
		DB_USER = properties.getProperty("jdbc_username");
		DB_PASSWORD = properties.getProperty("jdbc_password");
	}
	

	/**
	 * 批量插入
	 * 
	 * @param file
	 * @param insertTableSQL
	 * @param batchNo 
	 * @param status
	 * @return 
	 * @throws IOException 
	 * @throws FileNotFoundException 
	 */
	public int batchInsert(MultipartFile file, String insertTableSQL, int num, int status) throws IOException {
		try {
			doFirst();
		} catch (IOException e2) {
			throw e2;
		}
		long time = System.currentTimeMillis();
		IRowReader reader = null;
		/* 连接 */
		init(insertTableSQL);
		/* 运营EXCEL导入一 ，则使用 JDBCRowReader */
		if (status == importExcelNum) {
			reader = new JDBCRowReader(this, num);
		}

		try {
			/* 处理EXCEL */
			ExcelReaderUtil.readExcel(reader, file);
			/* 最后提交一次 */
			comit();
		} catch (SQLException e) {
			try {
				dbConnection.rollback();
			} catch (SQLException e1) {
				e1.printStackTrace();
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (preparedStatement != null) {
				try {
					preparedStatement.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
			if (dbConnection != null) {
				try {
					dbConnection.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		time = System.currentTimeMillis() - time;
		return reader.getSum();
	}

	/**
	 * 得到dbConnection
	 * 
	 * @return
	 */
	private Connection getDBConnection() {
		try {
			Class.forName(DB_DRIVER);
		} catch (ClassNotFoundException e) {
			System.out.println(e.getMessage());
		}
		try {
			dbConnection = DriverManager.getConnection(DB_CONNECTION, DB_USER, DB_PASSWORD);
			return dbConnection;
		} catch (SQLException e) {
			System.out.println(e.getMessage());
		}
		return dbConnection;
	}

	/**
	 * 批量执行初始化操作
	 * 
	 * @param insertTableSQL
	 */
	private void init(String insertTableSQL) {
		dbConnection = getDBConnection();
		try {
			preparedStatement = dbConnection.prepareStatement(insertTableSQL);
			dbConnection.setAutoCommit(false);
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 提交数据
	 * 
	 * @param dbConnection
	 * @param preparedStatement
	 * @throws SQLException
	 */
	public void comit() throws SQLException {
		preparedStatement.executeBatch();
		dbConnection.commit();
	}
}
