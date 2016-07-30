/* 共用toolFlag时的时间标志 */
var commonCon = "";
var showSqlId = "";
/* 初始化 */
$(function() {
	$("#content").css("width", $(window).width() * 0.785);
	$("#content").css("height", $(window).height() * 1.3);
	navgChange();
	/* 取flag */
	var tempStr = file.substring(file.indexOf("?") + 1, file.length);
	var strs = tempStr.split("|");
	var flagStr = [];
	for (var i in strs) {
		if (strs[i].indexOf("reportFlag") != -1) {
			flagStr = strs[i].split("=");
		}
		if (strs[i].indexOf("conFlag") != -1) {
			var commonCons = strs[i].split("=");
			commonCon = commonCons[1];
		}
	} /* 根据URL后面的报表标志从数据库中找到存储的public，condition，chart信息 */
	$.ajax({
		url: "report/queryAll",
		type: "POST",
		cache: false,
		data: {
			reportFlag: flagStr[1],
			conFlag: commonCon
		},
		dataType: "json",
		success: function(data) {
			if (data.code == 0) {
				data = data.data; /* 展示图形列表 */
				chartList = data.reportChartList == undefined ? [] : data.reportChartList;
				oldChartList = chartList;
				if (chartList.length > 0) {
					$(".particle").empty();
					for (var i = 0; i < chartList.length; i++) {
						if (i == 0) {
							$(".particle").append("<li class=\"on\" particle=\"-30\" default=\"on\">" + chartList[i].chartName + "</li>");
							currentChartName = chartList[i].chartName;
						} else {
							$(".particle").append("<li particle=\"-30\">" + chartList[i].chartName + "</li>");
						}
					}
				} else {
					$("#chartOption").hide();
					//<div id='middle' style='height:35%; width:93%;'>
				} /* 拼表格 */
				ecolumn = [];
				ccolumn = []; /* 格式化表格展示 */
				toolEColumn = data.reportPublic.toolEColumn;
				toolEColumn = toolEColumn.split(","); /* 格式化colModel */
				$.each(toolEColumn, function(n, value) {
					var obj = new Object();
					obj.name = value;
					obj.index = value;
					ecolumn.push(obj);
				});
				formatCols = data.reportPublic.toolFormat;
				toolGather = data.reportPublic.toolGather;
				toolCColumn = data.reportPublic.toolCColumn;
				toolCColumn = toolCColumn.split(",");

				var ecindex = 0;
				for (var i = 0; i < toolCColumn.length; i++) {
					if (toolCColumn[i].indexOf(":") != -1 && toolCColumn[i].indexOf("{") != -1 && toolCColumn[i].indexOf("}") != -1) {
						groupFlag = true; /* 拼装groupHeader */
						var obj = new Object();
						obj.titleText = toolCColumn[i].substring(0, toolCColumn[i].indexOf(":"));
						obj.numberOfColumns = toolCColumn[i].substring(toolCColumn[i].indexOf("{"), toolCColumn[i].indexOf("}")).split("|").length;
						/* 拼装colNames */
						var tmpArr = [];
						tmpArr = toolCColumn[i].substring(
						toolCColumn[i].indexOf("{") + 1, toolCColumn[i].indexOf("}")).split("|");
						obj.startColumnName = ecolumn[ecindex].name;
						groupHeader.push(obj);
						ccolumn = $.merge(ccolumn, tmpArr);
						ecindex = ecindex + obj.numberOfColumns;
					} else {
						ccolumn.push(toolCColumn[i]);
						ecindex++;
					}
				}
				loadTitle = data.reportPublic.toolCColumn;

				reportTitle = data.reportPublic.toolTitle;
				
				/* 取sql */
				hsql = (data.reportPublic.toolHSqlId == undefined ? "" : data.reportPublic.toolHSqlId);
				dsql = (data.reportPublic.toolDSqlId == undefined ? "" : data.reportPublic.toolDSqlId);
				wsql = (data.reportPublic.toolWSqlId == undefined ? "" : data.reportPublic.toolWSqlId);
				msql = (data.reportPublic.toolMSqlId == undefined ? "" : data.reportPublic.toolMSqlId);
				qsql = (data.reportPublic.toolQSqlId == undefined ? "" : data.reportPublic.toolQSqlId);
				ysql = (data.reportPublic.toolYSqlId == undefined ? "" : data.reportPublic.toolYSqlId);

				topNavInit (hsql,dsql,wsql,msql,qsql,ysql);
				
				/* 点击格式化的时候触发该事件，准备格式化数据 */
				var formatDatas = [];
				var toolFormat = data.reportPublic.toolFormat;
				if (toolFormat != undefined && toolFormat != "") {
					toolFormat = toolFormat.split(","); /* 金额:负数,笔数:百分比, */
					for (var k = 0; k < toolFormat.length; k++) {
						if (toolFormat[k] != "") {
							var tmpFmt = toolFormat[k].split(":");
							var formatSelect = tmpFmt[0];
							var columnType = tmpFmt[1];
							var obj = new Object();
							var fmtObj = new Object();
							if (columnType == "正整数") {
								obj.name = formatSelect;
								obj.formatter = "integer";
								fmtObj.thousandsSeparator = ",";
								fmtObj.defaultValue = "0";
								obj.formatoptions = fmtObj;
							} else if (columnType == "小数") {
								obj.name = formatSelect;
								obj.formatter = "number";
								fmtObj.decimalSeparator = ".";
								fmtObj.thousandsSeparator = ",";
								fmtObj.decimalPlaces = 2;
								fmtObj.defaultValue = "0.00";
								obj.formatoptions = fmtObj;
							} else if (columnType == "负数") {
								obj.name = formatSelect;
								obj.formatter = "currency";
								fmtObj.decimalSeparator = ".";
								fmtObj.thousandsSeparator = ",";
								fmtObj.decimalPlaces = "2";
								fmtObj.prefix = "-";
								fmtObj.defaultValue = "-0.00";
								obj.formatoptions = fmtObj;
							} else if (columnType == "百分比") {
								obj.name = formatSelect;
								obj.formatter = "currency";
								fmtObj.decimalSeparator = ".";
								fmtObj.thousandsSeparator = ",";
								fmtObj.decimalPlaces = "2";
								fmtObj.defaultValue = "0.00%";
								fmtObj.suffix = "%";
								obj.formatoptions = fmtObj;
							}
							formatDatas.push(obj);
						}
					} /* 格式化表格 */
					if (formatDatas.length > 0) {
						for (var i = 0; i < formatDatas.length; i++) {
							for (var j = 0; j < ccolumn.length; j++) {
								if (formatDatas[i].name == ccolumn[j]) {
									var obj = new Object();
									obj.name = ecolumn[j].name;
									obj.index = ecolumn[j].index;
									obj.formatter = formatDatas[i].formatter;
									obj.formatoptions = formatDatas[i].formatoptions;
									ecolumn[j] = obj;
								}
							}
						}
					}

				}

				/* 拼条件 */
				var conList = data.reportConditionList;
				
				var maxRowNum = 0;
				/* 每个条件行占%的高度 */
				var headHeightPx = 3;
				/* 计算行数 */
				for (i in conList) {
					if (maxRowNum < conList[i].rowNum) {
						maxRowNum = conList[i].rowNum;
					}
				}
				/* 初始化每行的div */
				$("#head").css("height" , (maxRowNum+1) * headHeightPx + "%");
				/* 每个head行所占的高度百分比 */
				var conHeadHighPer = 100 / (maxRowNum+1);
				for (var m = 1; m <= maxRowNum+1; m++) {
					$("#head").append("<div id='head" + m + "' style='height:" + conHeadHighPer + "%;text-align: left; margin-top: 6px;'></div>");
				}
				
				for (i in conList) {
					var conValueArry = new Array();
					/* 若select和checkBox是sql则先查询该sql的结果 */
					if (conList[i].conOption == "select" || conList[i].conOption == "checkbox") {
						var conValue = conList[i].conMuti;
						if (conValue.indexOf("select") != -1) {
							$.ajax({
								type: "post",
								url: "report/getConValue",
								dataType: 'json',
								async: false,
								data: {
									selectSql: conValue
								},
								success: function(data) {
									if (data.code == 0) {
										conValue = data.data;
									} else {
										jAlert(data.msg, '警告')
									}
								}
							});
						}
						conValue = replaceDot(conValue);
						conValueArry = conValue.split(',');
					}

					/* 显示页面条件 */
					if (conList[i].conOption == "input") {
						if (conList[i].display == "Y") {
							$("#head" + conList[i].rowNum).append(conList[i].conName + "<span style='margin-left: 10px;'></span><input type='text' name='" + conList[i].conWhere + "'/><span style='margin-left: 10px;'></span>");
						} else {
							$("#head").append("<input type='hidden'  name='" + conList[i].conWhere + "' value='"+ conList[i].value +"'/>");
						}
						
						if (conList[i].conType == "日期" && conList[i].display == "Y") {
							datePickInit($("input[name='" + conList[i].conWhere + "']"), conList[i].conName);
						}
						
						var obj = new Object();
						obj.name = conList[i].conWhere;
						obj.value = $("input[name='" + conList[i].conWhere + "']").val();
						obj.option = conList[i].conType;
						obj.conName = conList[i].conName;
						obj.type = "input";
						obj.conDefaultValue = conList[i].conDefaultValue;
						conData.push(obj);
					} else if (conList[i].conOption == "select") {
						if (conList[i].conType == "模糊查询") {
							$("#head" + conList[i].rowNum).append(conList[i].conName + "<span style='margin-left: 10px;'/><div class='dynamicDiv'><span style='margin-left: 10px;'></span><input type='text' style='width:200px;' name='input"+conList[i].conWhere+"'><ul class='dynamicUl' name='ul"+conList[i].conWhere+"'></ul></div>");
				        	var dynamicName = conValueArry;
				        	var conWhere = conList[i].conWhere;
				        	$("input[name='input" + conWhere + "']").attr("placeholder",dynamicName[0]);
				        	$("input[name='input" + conWhere + "']").focus(function(){
			        		if ($("input[name='input" + conWhere + "']").val() == "") {
			        			for(var i=0;i<dynamicName.length;i++){
			        				if (dynamicName[i].length >= 12) {
			        					$("ul[name='ul" + conWhere + "']").append("<li><a href=\"#\" style=\"color:black\" onclick=\"inDynamicName('"+dynamicName[i]+"','"+ conWhere +"')\">"+dynamicName[i].substring(0,10)+"...</a></li>");	
			        				} else
			        					$("ul[name='ul" + conWhere + "']").append("<li><a href=\"#\" style=\"color:black\" onclick=\"inDynamicName('"+dynamicName[i]+"','"+ conWhere +"')\">"+dynamicName[i]+"</a></li>");
			        			}
			        		}
			        		$("ul[name='ul" + conWhere + "']").show();
				        	});
				        	
				        	$("input[name='input" + conWhere + "']").bind('input propertychange', function() {
				        		var getDynamicName = $("input[name='input" + conWhere + "']").val(); 
				        		$("ul[name='ul" + conWhere + "']").html("");
				        		for(var i=0;i<dynamicName.length;i++){
				        			if (dynamicName[i] != null && dynamicName[i].indexOf(getDynamicName) > -1) {
				        				if (dynamicName[i].length >= 12) {
				        					$("ul[name='ul" + conWhere + "']").append("<li><a href=\"#\" style=\"color:black\" onclick=\"inDynamicName('"+dynamicName[i]+"','"+ conWhere +"')\">"+dynamicName[i].substring(0,10)+"...</a></li>");
				        				} else 
				        					$("ul[name='ul" + conWhere + "']").append("<li><a href=\"#\" style=\"color:black\" onclick=\"inDynamicName('"+dynamicName[i]+"','"+ conWhere +"')\">"+dynamicName[i]+"</a></li>");
				        			}
				        		}
				        	});
				        	var obj = new Object();
							obj.name = conList[i].conWhere;
							obj.option = "模糊查询";
							obj.conName = conList[i].conName;
							obj.value = $("input[name='" + conList[i].conWhere + "']").val();
							obj.type = "select";
							conData.push(obj);
						} else {
							$("#head" + conList[i].rowNum).append(
									conList[i].conName + "<span style='margin-left: 10px;'></span><select id='conValueSelect" + i + "' name='" + conList[i].conWhere + "'></select>");
									$.each(conValueArry, function(n, value) {
										$("#conValueSelect" + i).append("<option value='" + value + "'>" + value + "</option>");
									});
									var obj = new Object();
									obj.name = conList[i].conWhere;
									obj.option = "文本";
									obj.conName = conList[i].conName;
									obj.value = $("select[name='" + conList[i].conWhere + "'] :selected").val();
									obj.type = "select";
									conData.push(obj);
						}
						
					} else if (conList[i].conOption == "checkbox") {
						$("#head" + conList[i].rowNum).append(
						conList[i].conName);
						$.each(
						conValueArry, function(n, value) {
							$("#head" + conList[i].rowNum).append("<span style='margin-left: 10px;'></span><input type='checkbox' name='" + conList[i].conWhere + "' value='" + value + "'>" + value + "</input>");
						});
						var chk_value_show = "";
						$("input[name='" + conList[i].conWhere + "']:checked").each(

						function() {
							chk_value_show = chk_value_show + $(this).val() + ",";
						});
						var obj = new Object();
						obj.name = conList[i].conWhere;
						obj.conName = conList[i].conName;
						obj.option = "文本";
						obj.value = chk_value_show;
						obj.type = "checkbox";

						obj.checkboxName = conList[i].conName;
						conData.push(obj);
					}
				}
				var conHeadNum = maxRowNum+1;
				$("#head" + conHeadNum).append("<input type='button' onclick='look()' value='查看'/><span style='margin-left: 10px;'></span>");
				$("#head" + conHeadNum).append("<input type='button' onclick='loadReport()' value='导出Excel'/>");
				// 拼图
				imgInit();
				time();
				// initJqGrid(toolCColumn, toolEColumn);
			} else {
				$("#mainContainer").html("请求错误");
			}
		}
	});
});

//为日期选择相应维度控件
function datePickInit (conNode, conName) {
	var time = $('.currentItem a').attr('time');
	conNode.removeClass("hasDatepicker");
	if (time == "日") {
		if (conName.indexOf("开始") != -1 || conName.indexOf("begin") != -1) {
			dayPickerBeginInit(conNode);
		} else if (conName.indexOf("结束") != -1 || conName.indexOf("end") != -1) {
			dayPickerEndInit(conNode);
		}
	} else if (time == "周") {
		if (conName.indexOf("开始") != -1 || conName.indexOf("begin") != -1) {
			weekPickerBeginInit(conNode);
		} else if (conName.indexOf("结束") != -1 || conName.indexOf("end") != -1) {
			weekPickerEndInit(conNode);
		}
	} else if (time == "月") {
		monthPickerInit(conNode);
	}
}