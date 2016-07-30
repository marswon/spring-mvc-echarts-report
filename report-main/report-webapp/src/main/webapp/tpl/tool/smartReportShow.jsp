<%@ page language="java" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script src="${pageContext.request.contextPath}/js/reportShow.js"
	type="text/javascript"></script>
<script type="text/javascript">
	var resizeOption;
	var effect = [ 'spin', 'bar', 'ring', 'whirling', 'dynamicLine', 'bubble' ];
	var qid = "";
	var myChart = null;
	var oldChartList = [];
	/* colModel */
	var ecolumn = [];
	/* colName */
	var ccolumn = [];

	var toolCColumn = [];
	var toolEColumn = [];
	/* 汇总列 */
	var toolGather = [];
	/* 二级表头 */
	var groupHeader = [];
	var groupFlag = false;
	/* 图形对象数组 */
	var chartList = []
	var currentChartName = "";
	var chartShowName = [];
	//var chartOption = [];
	//var option = [];
	var reportTitle = "";
	var loadTitle = "";
	var conData = [];
	var formatCols = "";

	/* 替换中文逗号 */
	function replaceDot(str) {
		var oldValue = str;
		while (oldValue.indexOf("，") != -1) {
			str = oldValue.replace("，", ",");
			oldValue = str;
		}
		return oldValue;
	}
	/* 克隆 */
	function objClone(obj) {
		var newobj, str;
		if (typeof obj !== 'object') {
			return;
		} else if (window.JSON) {
			str = JSON.stringify(obj), //系列化对象
			newobj = JSON.parse(str); //还原
		} else {
			for ( var i in obj) {
				newobj[i] = typeof obj[i] === 'object' ? cloneObj(obj[i])
						: obj[i];
			}
		}
		return newobj;
	};

	/* 判断该对象是否在数组中，模仿map,ie8不支持map */
	function objIsInArr(mapObj, mapObjs) {
		for (var i = 0; i < mapObjs.length; i++) {
			if (mapObjs[i].name == mapObj) {
				return true;
			}
		}
		return false;
	}
	/* 根据name得到该对象的value,模仿map[name],ie8不支持map */
	function getObjInArr(name, mapObjs) {
		for (var i = 0; i < mapObjs.length; i++) {
			if (mapObjs[i].name == name) {
				return mapObjs[i].value;
			}
		}
		return null;
	}

	/* 兼容ie8 new Date('yyyy-mm-dd')*/
	function parseISO8601(dateStringInRange) {
		var isoExp = /^\s*(\d{4})-(\d\d)-(\d\d)\s*$/, date = new Date(NaN), month, parts = isoExp
				.exec(dateStringInRange);
		if (parts) {
			month = +parts[2];
			date.setFullYear(parts[1], month - 1, parts[3]);
			if (month != date.getMonth() + 1) {
				date.setTime(NaN);
			}
		}
		return date;
	}

	/* 查看报表 */
	function look() {
		//var map = {};
		var mapObjs = [];
		var begintime = 1;
		var endtime = 1;
		for ( var i in conData) {
			if (conData[i].type == "input") {
				if (conData[i].conName == "开始时间") {
					begintime = $("input[name='" + conData[i].name + "']")
							.val();
					begintime = begintime.replace(/[-]/g, "");
				} else if (conData[i].conName == "结束时间") {
					endtime = $("input[name='" + conData[i].name + "']").val();
					endtime = endtime.replace(/[-]/g, "");
				}
			}
		}
		if ((begintime != 1 && endtime != 1 && begintime > endtime)
				|| begintime == '' || endtime == '') {
			jAlert('请选择正确的时间！', '警告');
			return;
		}
		for ( var i in conData) {
			if (conData[i].type == "input") {
				conData[i].value = $("input[name='" + conData[i].name + "']").val();

				/* 判断时间是否超过限制 */
				if (conData[i].conDefaultValue != null
						&& conData[i].conDefaultValue != "") {

					if (objIsInArr(conData[i].conDefaultValue, mapObjs)) {
						/* 时间差 */
						var timeC = (getObjInArr(conData[i].conDefaultValue,
								mapObjs) - parseISO8601(conData[i].value))
								/ (24 * 60 * 60 * 1000);
						if (timeC < 0) {
							timeC = -timeC;
						}
						timeC++;
						var dftDatas = conData[i].conDefaultValue.split(",");

						if (timeC < dftDatas[0]) {
							jAlert('请选择合理的查询时间范围（' + dftDatas[0] + '至'
									+ dftDatas[1] + '天）！', '警告');
							return;
						}

						if (timeC > dftDatas[1]) {
							jAlert('请选择合理的查询时间范围（' + dftDatas[0] + '至'
									+ dftDatas[1] + '天）！', '警告');
							return;
						}
					} else {
						var mapObj = new Object();
						mapObj.name = conData[i].conDefaultValue;
						mapObj.value = parseISO8601(conData[i].value);
						mapObjs.push(mapObj);
					}
				}

			} else if (conData[i].type == "select") {
				if (conData[i].option=='模糊查询') {
					if ($("input[name='input" + conData[i].name + "']").val()=="") {
						conData[i].value = $("input[name='input" + conData[i].name + "']").attr("placeholder");
					} else {
						conData[i].value = $("input[name='input" + conData[i].name + "']").val();
					}
				} else {
					conData[i].value = $("select[name='" + conData[i].name + "'] :selected").val();
				}
			} else if (conData[i].type == "checkbox") {
				var chk_value_show = "";
				$("input[name='" + conData[i].name + "']:checked").each(
						function() {
							chk_value_show = chk_value_show + $(this).val()
									+ ",";
						});

				if (chk_value_show == "") {
					jAlert("请勾选要查询的" + conData[i].checkboxName + "！", "警告");
					return;
				}
				conData[i].value = chk_value_show;
			}
		}
		myChart.showLoading({
			text : '数据查询中',
			effect : effect[3],
			textStyle : {
				fontSize : 20
			}
		});
		$("#list").jqGrid('GridUnload');//重新构造
		initJqGrid(toolCColumn, toolEColumn);
	}

	/* 导出报表 */
	function loadReport() {
		//var map = {};

		var mapObjs = [];
		var begintime = 1;
		var endtime = 1;
		for ( var i in conData) {
			if (conData[i].type == "input") {
				if (conData[i].conName == "开始时间") {
					begintime = $("input[name='" + conData[i].name + "']")
							.val();
					begintime = begintime.replace(/[-]/g, "");
				} else if (conData[i].conName == "结束时间") {
					endtime = $("input[name='" + conData[i].name + "']").val();
					endtime = endtime.replace(/[-]/g, "");
				}
			}
		}
		if ((begintime != 1 && endtime != 1 && begintime > endtime)
				|| begintime == '' || endtime == '') {
			jAlert('请选择正确的时间！', '警告');
			return;
		}
		for ( var i in conData) {
			if (conData[i].type == 'input') {
				conData[i].value = $("input[name='" + conData[i].name + "']")
						.val();
				/* 判断时间是否超过限制 */
				if (conData[i].conDefaultValue != null
						&& conData[i].conDefaultValue != "") {
					if (conData[i].value == "") {
						jAlert('请选择要查询的时间范围！', '警告');
						return;
					}
					if (objIsInArr(conData[i].conDefaultValue, mapObjs)) {
						/* 时间差 */
						var timeC = (getObjInArr(conData[i].conDefaultValue,
								mapObjs) - parseISO8601(conData[i].value))
								/ (24 * 60 * 60 * 1000);
						if (timeC < 0) {
							timeC = -timeC;
						}
						timeC++;
						var dftDatas = conData[i].conDefaultValue.split(",");

						if (timeC < dftDatas[0]) {
							jAlert('请选择合理的查询时间范围（' + dftDatas[0] + '至'
									+ dftDatas[1] + '天）！', '警告');
							return;
						}

						if (timeC > dftDatas[1]) {
							jAlert('请选择合理的查询时间范围（' + dftDatas[0] + '至'
									+ dftDatas[1] + '天）！', '警告');
							return;
						}
					} else {
						var mapObj = new Object();
						mapObj.name = conData[i].conDefaultValue;
						mapObj.value = parseISO8601(conData[i].value);
						mapObjs.push(mapObj);
					}
				}

			} else if (conData[i].type == 'select') {
				
				conData[i].value = $("select[name='" + conData[i].name + "']")
						.val();
			} else if (conData[i].type == 'checkbox') {
				var chk_value_show = "";
				$("input[name='" + conData[i].name + "']:checked").each(
						function() {
							chk_value_show = chk_value_show + $(this).val()
									+ ",";
						});
				if (chk_value_show == "") {
					jAlert("请勾选要查询的" + conData[i].checkboxName + "！", "警告");
					return;
				}
				conData[i].value = chk_value_show;
			}
		}
		var title = loadTitle;
		var fileName = reportTitle;
		var conditions = JSON.stringify(conData);

		$("#title").val(title);
		$("#fileName").val(fileName);
		$("#qid").val(qid);
		$("#condition").val(conditions);
		$("#formatCols").val(formatCols);
		$("#loadFormId").submit();
	}

	/* echarts图表初始化 */
	function imgInit() {
		require
				.config({
					paths : {
						'echarts' : '${pageContext.request.contextPath}/js/echarts', //echarts.js的路径
						'echarts/chart/line' : '${pageContext.request.contextPath}/js/echarts', //echarts.js的路径
						'echarts/chart/bar' : '${pageContext.request.contextPath}/js/echarts'
					}
				});
		require([ 'echarts', 'echarts/chart/line', 'echarts/chart/bar' ],
				DrawEChart);
		//渲染ECharts图表

	}

	/* 图表回调函数 */
	function DrawEChart(ec) {
		/* 图表渲染的容器对象 */
		var chartContainer = document.getElementById("echart");
		/* 加载图表 */
		myChart = ec.init(chartContainer);
		//myChart.setOption(option);
		/* 动态添加默认不显示的数据 */
		var ecConfig = require('echarts/config');
		myChart.on(ecConfig.EVENT.LEGEND_SELECTED, function(param) {
			var selected = param.selected;
			//changeLine(selected);
		});
	}

	function isJson(obj) {
		var isjson = typeof (obj) == "object"
				&& Object.prototype.toString.call(obj).toLowerCase() == "[object object]"
				&& !obj.length;
		return isjson;
	}

	$('#chartOption').on('click', '.particle li', function() {
		//debugger;
		$('.particle li').removeClass('on');
		//$(this).addClass('on');
		$(this).addClass('on');
		currentChartName = $(this).text();
		showChart($(this).text());
	});

	/* 展现图表 */
	function showChart(chartName) {
		/* toolCColumn,toolEColumn */
		if (chartList.length > 0) {
			//<li particle="-30" default="on" class="on">呵呵啊</li>
			//$(".charts").removeClass('on');
			for (var i = 0; i < chartList.length; i++) {
				/*展示选中的图*/
				if (chartList[i].chartName == chartName) {
					var columnVsLegend = chartList[i].dataVsLe;
					var columnVsX = chartList[i].dataVsX;
					var option = chartList[i].chartOption;
					if (option.length > 0) {
						if (!isJson(option)) {
							option = eval('(' + option + ')');
						}
					}
					/* e.g result:结果,sumAmt:金额,sumcnt:笔数 */
					var columnVsLegends = columnVsLegend.split(",");
					/* option.series赋值  */
					$.each(columnVsLegends, function(n, value) {
						var strs = value.split(":");
						$.each(option.series, function(n, value) {
							if (value.name == strs[1]) {
								/* 正常显示 */
								var tempArr = jQuery("#list").jqGrid('getCol',
										strs[0]).reverse();
								for (var i = 0; i < tempArr.length; i++) {
									tempArr[i] = Number(tempArr[i]);
								}
								if (columnVsX.indexOf("|") != -1) {

									/* 分组显示 */
									var type = columnVsX.split("|");
									var typeArr = jQuery("#list").jqGrid(
											'getCol', type[1]).reverse();
									var beginNum = $.inArray(currentChartName,
											typeArr);
									var endNum = lastIndex(currentChartName,
											typeArr);
									if (beginNum == -1 && endNum == -1) {

									} else {
										tempArr = tempArr.splice(beginNum,
												endNum + 1);
									}
								}
								value.data = tempArr;
							}
						});
					});

					/* tx_date:日期   tx_date:日期|tran_type */
					var xdatas = columnVsX.split(":");
					/* 正常显示 */
					if (columnVsX.indexOf("|") == -1) {
						if (option.xAxis.length == 1) {
							option.xAxis[0].data = jQuery("#list").jqGrid(
									'getCol', xdatas[0]).reverse();
						} else if (option.xAxis.length == 2) {
							option.xAxis[0].data = jQuery("#list").jqGrid(
									'getCol', xdatas[0]).reverse();
							option.xAxis[1].data = jQuery("#list").jqGrid(
									'getCol', xdatas[0]).reverse();
						}
					} else {
						/* 分组显示 */
						var type = columnVsX.split("|");
						var typeArr = jQuery("#list").jqGrid('getCol', type[1])
								.reverse();
						var beginNum = $.inArray(currentChartName, typeArr);
						var endNum = lastIndex(currentChartName, typeArr);
						if (beginNum == -1 && endNum == -1) {
							option.xAxis[0].data = jQuery("#list").jqGrid(
									'getCol', xdatas[0]).reverse();
						} else {
							option.xAxis[0].data = arrUnique(jQuery("#list")
									.jqGrid('getCol', xdatas[0]).reverse());
						}
					}
					resizeOption = option;
					myChart.setOption(option, true);
				}
			}
		}
	}

	/* 判断一个字符串在该数组最后一次出现的位置,兼容ie8.不能用lastIndexOf */
	function lastIndex(str, list) {
		var lastIndexNum = -1;
		for (var i = 0; i < list.length; i++) {
			if (list[i] == str) {
				lastIndexNum = i;
			}
		}
		return lastIndexNum;
	}

	function time() {

		for (var i = 0; i < conData.length; i++) {
			if (conData[i].type == "input" && conData[i].option == "日期") {
				datePickInit($("input[name='" + conData[i].name + "']"),
						conData[i].conName);
			}
		}
		var time = $('.currentItem a').attr('time');

		if (time == '时') {
			if (hsql != "") {
				$('#mainContainer').show();
				qid = hsql;
			} else {
				$('#mainContainer').hide();
			}
		}
		if (time == '日') {
			if (dsql != "") {
				$('#mainContainer').show();
				qid = dsql;
			} else {
				$('#mainContainer').hide();
			}
		}
		if (time == '周') {
			if (wsql != "") {
				$('#mainContainer').show();
				qid = wsql;
			} else {
				$('#mainContainer').hide();
			}
		}
		if (time == '月') {
			if (msql != "") {
				$('#mainContainer').show();
				qid = msql;
			} else {
				$('#mainContainer').hide();
			}
		}
		if (time == '季') {
			if (qsql != "") {
				$('#mainContainer').show();
				qid = qsql;
			} else {
				$('#mainContainer').hide();
			}
		}
		if (time == '年') {
			if (ysql != "") {
				$('#mainContainer').show();
				qid = ysql;
			} else {
				$('#mainContainer').hide();
			}
		}
	}

	function showChangeReport(file) {
		if (file.indexOf('tpl/tool/smartReportShow.jsp') != -1) {
			time();
			if (doLast()) {
				return;
			}
			look();
		}
	}

	function doLast() {
		var begintime = 1;
		var endtime = 1;
		for ( var i in conData) {
			if (conData[i].type == "input") {
				if (conData[i].conName == "开始时间") {
					begintime = $("input[name='" + conData[i].name + "']")
							.val();
					begintime = begintime.replace(/[-]/g, "");
				} else if (conData[i].conName == "结束时间") {
					endtime = $("input[name='" + conData[i].name + "']").val();
					endtime = endtime.replace(/[-]/g, "");
				}
			}
		}
		if (begintime == '' && endtime == '') {
			return 1;
		}
		return 0;
	}
	function changeLine(selected) {

	}

	/* 查询表格数据 */
	function initJqGrid(toolCColumn, toolEColumn) {
		chartList = objClone(oldChartList);
		jQuery("#list")
				.jqGrid(
						{
							url : 'report/reportShowQueryData',
							datatype : "json",
							mtype : 'post',
							colNames : ccolumn,
							colModel : ecolumn,
							height : $(window).height() * 0.25,
							width : $(window).width() * 0.75,
							postData : {
								qid : qid,
								condition : JSON.stringify(conData)
							},
							rowNum : 200,
							rowList : [ 20, 30, 50 ,100, 200 ],
							pager : '#pager',
							sortname : 'rp_date',
							viewrecords : true,
							sortorder : "desc",
							caption : reportTitle,
							footerrow : true,
							userDataOnFooter : true,
							altRows : true,
							loadError : function(xhr, status, error) {
								myChart.hideLoading();
								myChart.clear();
								jAlert("该报表出现问题,已记录,我们会尽快修复", "提示");
							},
							loadComplete : function() {
								myChart.hideLoading();
								//myChart.clear();
								var re_records = $("#list").getGridParam(
										'records');
								if (re_records != null && re_records != "") {
									reconstruct();
									if (chartList.length > 0) {
										showChart(currentChartName);
									}
									/* 汇总功能 */
									if (toolGather != null && toolGather != "") {
										var gathers = toolGather.split(",");
										var gatheJson = "";
										if (gathers.length > 0) {
											for (var j = 0; j < gathers.length; j++) {
												for (var k = 0; k < ccolumn.length; k++) {
													if (ccolumn[k] == gathers[j]) {
														var gatherJsonKey = ecolumn[k].name;
														var dataList = jQuery(
																"#list")
																.jqGrid(
																		'getCol',
																		gatherJsonKey);
														gatheJson = gatheJson
																+ gatherJsonKey
																+ ":"
																+ getTotleNum(
																		dataList)
																		.toFixed(
																				2)
																+ ",";
													} else if (gathers[j]
															.indexOf("|") != -1) {
														sumColumns = gathers[j]
																.split("|");
														if (ccolumn[k] == sumColumns[0]) {
															var gatherJsonKey = ecolumn[k].name;
															gatheJson = gatheJson
																	+ gatherJsonKey
																	+ ":'"
																	+ sumColumns[1]
																	+ "',";
														}
													}
												}
											}
											gatheJson = "{"
													+ gatheJson
															.substring(
																	0,
																	gatheJson.length - 1)
													+ "}";
											jQuery("#list")
													.jqGrid(
															'footerData',
															'set',
															eval('('
																	+ gatheJson
																	+ ')'));
										}
									}
								} else {
									myChart.clear();
								}
							},
							gridComplete : function() {

							}
						});
		/* 页数显示 */
		jQuery("#list").jqGrid('navGrid', '#pager', {
			edit : false,
			add : false,
			del : false
		}, {}, {}, {}, {
			multipleSearch : true,
			multipleGroup : false
		});
		/* 二级表头 */
		if (groupFlag) {
			jQuery("#list").jqGrid('setGroupHeaders', {
				useColSpanStyle : true,
				groupHeaders : groupHeader
			});
		}
	}

	/* 判断是否需要重新构造 */
	function reconstruct() {
		for (var i = 0; i < chartList.length; i++) {
			if (chartList[i].chartName == currentChartName) {
				var columnVsLegend = chartList[i].dataVsLe;
				var columnVsX = chartList[i].dataVsX;
				var option = chartList[i].chartOption;
				if (option.length > 0) {
					if (!isJson(option)) {
						option = eval('(' + option + ')');
					}
				}

				/* 去重复得到需要重新构造的列数据,显示在图形界面上 */
				var reColumns = columnVsX.split("|");
				var reconstructColumn = jQuery("#list").jqGrid('getCol',
						reColumns[1]);
				reconstructColumn = arrUnique(reconstructColumn);

				if (chartList.length > 0) {
					$(".particle").empty();
					for (var i = 0; i < chartList.length; i++) {
						if (i == 0) {
							$(".particle").append(
									"<li class=\"on\" particle=\"-30\" default=\"on\">"
											+ chartList[i].chartName + "</li>");
							currentChartName = chartList[i].chartName;
						} else {
							$(".particle").append(
									"<li particle=\"-30\">"
											+ chartList[i].chartName + "</li>");
						}
					}
				}

				for (var i = 0; i < reconstructColumn.length; i++) {
					var newOption = new Object();
					for ( var n in chartList[i]) {
						newOption[n] = chartList[i][n];
					}
					$(".particle").append(
							"<li particle=\"-30\">" + reconstructColumn[i]
									+ "</li>");
					newOption.chartName = reconstructColumn[i];
					/* 组装option的数据,显示图形名称列表,除了ChartName不一样,其余都和之前一样,数据在显示图形的时候组装*/
					if ($.inArray(newOption, chartList) == -1) {
						chartList.push(newOption);
					}
				}
			}
		}
	}
	/* 数组去重 */
	function arrUnique(arr) {
		var res = [], hash = {};
		for (var i = 0, elem; (elem = arr[i]) != null; i++) {
			if (!hash[elem]) {
				res.push(elem);
				hash[elem] = true;
			}
		}
		return res;
	}

	/* 取数组的和 */
	function getTotleNum(list) {
		var sum = 0;
		for (var i = 0; i < list.length; i++) {
			sum = sum + list[i] * 1;
		}
		return sum;
	}
	/* 窗口自适应 */
	$(window).resize(function() {
		$("#content").css("width", $(window).width() * 0.785);
		myChart.resize();
		$("#list").setGridWidth($(window).width() * 0.75);
	});

	$(".js-selected").click(function(e) {
		e.stopPropagation();
		$("#searchAppMain").css("display", "block");
		$(".js-app-select").css("display", "none");
		$("#naselect").css("display", "none");
		$("#search-highlight").focus();
	});
</script>
<body>
	<div id='content'>
		<div id='head' style='font-size: initial; margin-bottom: 30px;'>

		</div>

		<div id="chartOption" class="mod mod1"
			style="height: 35%; width: 95%; padding-bottom: 30px;">

			<div class="mod-header radius clearfix">
				<h2></h2>
				<div class="option">
					<div class="particle js-um-tab" id="trends_period">
						<ul>
						</ul>
					</div>
				</div>
			</div>

			<div class="mod-body">
				<div id="echart"
					style="height: 100%; width: 98%; margin-left: auto; margin-right: auto;"></div>
			</div>
		</div>

		<div id='middle' style='height: 35%; width: 93%; float: left;'>
			<table id="list"></table>
			<div id="pager"></div>
		</div>
		<form action="exp/smartExpCsv" method="post" id="loadFormId">
			<input type="hidden" name="title" id="title" /> <input type="hidden"
				name="fileName" id="fileName" /> <input type="hidden" name="qid"
				id="qid" /> <input type="hidden" name="condition" id="condition" />
			<input type="hidden" name="formatCols" id="formatCols">
		</form>
	</div>
</body>
