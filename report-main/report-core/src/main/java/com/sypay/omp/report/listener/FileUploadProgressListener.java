package com.sypay.omp.report.listener;

import javax.servlet.http.HttpSession;

import org.apache.commons.fileupload.ProgressListener;

import com.sypay.omp.per.common.Constants;
import com.sypay.omp.report.domain.Progress;

/**
 * 
 * 创建人：lishun
 * 创建时间：2015-11-19
 * 功能描述： 文件上传进度监听
 */
public class FileUploadProgressListener implements ProgressListener {
	
	private HttpSession session;

	
	public FileUploadProgressListener() {  }  
	
    public FileUploadProgressListener(HttpSession session) {
        this.session=session;  
        Progress status = new Progress();
        Long memberId = (Long) session.getAttribute(Constants.SESSION_LOGIN_MEMBER_ID);
        session.setAttribute(memberId + "upload_ps", status);  
    }
	
	/**
	 * pBytesRead 到目前为止读取文件的比特数 pContentLength 文件总大小 pItems 目前正在读取第几个文件
	 */
	public void update(long pBytesRead, long pContentLength, int pItems) {
		Long memberId = (Long) session.getAttribute(Constants.SESSION_LOGIN_MEMBER_ID);
		Progress status = (Progress) session.getAttribute(memberId + "upload_ps");
		status.setBytesRead(pBytesRead);
		status.setContentLength(pContentLength);
		status.setItems(pItems);
		session.setAttribute(memberId + "upload_ps", status);
	}
}