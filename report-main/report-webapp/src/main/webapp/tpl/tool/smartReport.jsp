<%@ page language="java" pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<head>
<script type="text/javascript">
    var formatDatas = [];
    var ccolumn = [];
    var saveFormatDatas = "";
    /* 填写完中文列名,失去焦点时触发该事件 */
    $("#toolCColumn").blur(function(){
    	$("#columnName").empty();
        /* 解析中文列名,重新构造列表 */
        var toolCColumn = $("#toolCColumn").val();
        toolCColumn = replaceDot(toolCColumn);
        toolCColumn = toolCColumn.split(",");
        for (var i=0; i<toolCColumn.length; i++) {
    		if (toolCColumn[i].indexOf(":") != -1 && toolCColumn[i].indexOf("{") != -1 && toolCColumn[i].indexOf("}") != -1) {
   				tmpArr = toolCColumn[i].substring(toolCColumn[i].indexOf("{")+1, toolCColumn[i].indexOf("}")).split("|");
   				for (var j=0;j<tmpArr.length; j++) {
   					$("#columnName").append("<option value='"+ tmpArr[j] +"'>" + tmpArr[j] + "</option>");
   				}
    		} else {
    			$("#columnName").append("<option value='"+ toolCColumn[i] +"'>" + toolCColumn[i] + "</option>");
    		}
    	}
    });
    
    /* 点击格式化的时候触发该事件，准备格式化数据 */
    function formatClick() {
   		var formatSelect = $("#columnName  option:selected").text();
   		var columnType = $("#columnType  option:selected").text();
   		var flag = true;
   		var obj = new Object();
		var fmtObj = new Object();
		var saveFormatData = "";
   		if (columnType == "正整数") {
   			obj.name = formatSelect;
   			obj.formatter = "integer";
   			fmtObj.thousandsSeparator = ",";
   			fmtObj.defaultValue = "0";
   			obj.formatoptions = fmtObj;
   			saveFormatData = formatSelect + ":" + "正整数,";
   		} else if (columnType == "小数") {
   			obj.name = formatSelect;
   			obj.formatter = "number";
   			fmtObj.decimalSeparator = ".";
   			fmtObj.thousandsSeparator = ",";
   			fmtObj.decimalPlaces = 2;
   			fmtObj.defaultValue = "0.00";
   			obj.formatoptions = fmtObj;
   			saveFormatData = formatSelect + ":" + "小数,";
   		} else if (columnType == "负数") {
   			obj.name = formatSelect;
   			obj.formatter = "currency";
   			fmtObj.decimalSeparator = ".";
   			fmtObj.thousandsSeparator = ",";
   			fmtObj.decimalPlaces = "2";
   			fmtObj.prefix = "-";
   			fmtObj.defaultValue = "-0.00";
   			obj.formatoptions = fmtObj;
   			saveFormatData = formatSelect + ":" + "负数,";
   		} else if (columnType == "百分比") {
   			obj.name = formatSelect;
   			obj.formatter = "currency";
   			fmtObj.decimalSeparator = ".";
   			fmtObj.thousandsSeparator = ",";
   			fmtObj.decimalPlaces = "2";
   			fmtObj.defaultValue = "0.00%";
   			fmtObj.suffix = "%";
   			obj.formatoptions = fmtObj;
   			saveFormatData = formatSelect + ":" + "百分比,";
   		}
   		
   		/* 不插入重复的格式化数据 */
   		for (var i=0; i<formatDatas.length; i ++) {
			if (formatDatas[i].name == obj.name) {
				flag = false;
			}
		}
   		
		if (!flag) {
		    formatDatas.splice($.inArray(obj,formatDatas),1);
		    if (saveFormatDatas.indexOf(formatSelect) != -1) {
		    	var beginIndex = saveFormatDatas.indexOf(formatSelect);
		    	var endIndex = saveFormatDatas.indexOf(",", beginIndex);
		    	endIndex = (endIndex == -1? saveFormatDatas.length:endIndex);
		    	saveFormatDatas = saveFormatDatas.substring(0,beginIndex) +  saveFormatDatas.substring(endIndex+1);
		    }
		}
		
		formatDatas.push(obj);
		saveFormatDatas = saveFormatDatas + saveFormatData;
		queryData();
    }
    
    
	/* toolHead js */
	/* 生成toolEColumn */
	function initEcolumn() {
		var toolHSqlId = $("#toolHSqlId").val();
		$("#toolEColumn").val(initToolEColumn(toolHSqlId));
	}
    /* 查询数据 */
    function queryData() {
    	ccolumn = [];
        var conData = [];
        var toolTitle = $("#toolTitle").val();
        var toolGather = $("#toolGather").val();
        var toolCColumn = $("#toolCColumn").val();
        toolCColumn = replaceDot(toolCColumn);
        toolCColumn = toolCColumn.split(",");
        var toolHSqlId = $("#toolHSqlId").val();
        //$("#toolEColumn").val(initToolEColumn(toolHSqlId));
        /* 从sql中截取数据库展示字段 */
        var toolEColumn = $("#toolEColumn").val();
        toolEColumn = toolEColumn.split(",");
        /* 封装colModel */
        var ecolumn = [];
        $.each(toolEColumn, function(n, value){
       		var obj = new Object();
            obj.name = value;
            obj.index = value;
            ecolumn.push(obj);
        });
        $.each(conArr, function(n, value){
            var obj = new Object();
            var str = "";
            var chk_value ="";
            switch (value.option) {
            case "input":
                str = $("input[name='"+value.where+"']").val();
                obj.name=value.where;//{1}
                obj.value=str;
                obj.type="input";
                conData.push(obj);
                break;
            case "select":
            	if (value.type == '模糊查询') {
            		if ($("input[name='input"+value.where+"']").val() == "") {
            			str = $("input[name='input"+value.where+"']").attr("placeholder");
            		} else {
            			str = $("input[name='input"+value.where+"']").val();
            		}
            		
                    obj.name=value.where;
                    obj.value=str;
                    obj.type="select";
                    conData.push(obj);
            	} else {
            		str = $("select[name='"+value.where+"'] :selected").val();
                    obj.name=value.where;
                    obj.value=str;
                    obj.type="select";
                    conData.push(obj);
            	}
                break;
            case "checkbox":
                $("input[name='"+value.where+"']:checked").each(function(){ 
                    chk_value = chk_value + $(this).val() + ",";
                });
                obj.name=value.where;
                obj.value=chk_value;
                obj.type="checkbox";
                conData.push(obj);
                break;
            }
        });
        jqgrid(JSON.stringify(conData),toolTitle,toolCColumn,ecolumn,toolHSqlId, toolGather);
    }
    
    /* jqGird表格显示数据 */
    function jqgrid(conData,toolTitle,toolCColumn,ecolumn,toolHSqlId, toolGather) {
    	/*参数： conData:条件数据,toolTitile:标题,toolCColumn:中文列名,ecolumn:数据库列名,toolHSqlId:sql内容,toolGather:汇总数据的列 */
    	/* 处理二级表头   e.g [日期,金额:{成功金额|失败金额},笔数:{成功笔数|失败笔数}]*/
    	// str = $("select[name='"+value.where+"'] :selected").val();
		var groupHeader = [];
		var groupFlag = false;
		var ecindex = 1;
    	for (var i=0; i<toolCColumn.length; i++) {
    		if (toolCColumn[i].indexOf(":") != -1 && toolCColumn[i].indexOf("{") != -1 && toolCColumn[i].indexOf("}") != -1) {
    			groupFlag = true;
    			/* 拼装groupHeader */
    			var obj = new Object();
    			obj.titleText = toolCColumn[i].substring(0,toolCColumn[i].indexOf(":"));
    			obj.startColumnName = ecolumn[ecindex].name;
    			obj.numberOfColumns = toolCColumn[i].substring(toolCColumn[i].indexOf("{"),toolCColumn[i].indexOf("}")).split("|").length;
   				groupHeader.push(obj);
   				ecindex = ecindex + obj.numberOfColumns;
   				/* 拼装colNames */
   				var tmpArr = [];
   				tmpArr = toolCColumn[i].substring(toolCColumn[i].indexOf("{")+1, toolCColumn[i].indexOf("}")).split("|");
   				ccolumn = $.merge(ccolumn,tmpArr);
    		} else {
    			ccolumn.push(toolCColumn[i]);
    		}
    	}
    	/* 格式化表格 */
    	if (formatDatas.length > 0) {
    		for (var i=0; i<formatDatas.length; i++) {
    			for (var j=0;j<ccolumn.length; j++) {
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
    	
    	/* 重新构造表格 */
        $("#reportList").jqGrid('GridUnload');
        /* 输出表格 */
        jQuery("#reportList").jqGrid({
            url:'report/reportMakeQueryData',
            datatype: "json",
            mtype:'post',
            colNames:ccolumn,
            colModel:ecolumn,
            postData : {
                baseSql : toolHSqlId,
                condition : conData
            },
            height: $(window).height()*0.15,
            width:$(window).width()*0.9,
            //autowidth:true,
            rowNum:10,
            rowList:[10,20,30,50],
            pager: '#reportPager',
            sortname: '',
            viewrecords: true,
            sortorder: "desc",
            caption: toolTitle,
            footerrow : true,
    		userDataOnFooter : true,
    		altRows : true,
            loadComplete:function(data){
            	if (data.data != undefined) {
            		jAlert(data.data,'警告');
            	}
            },
            gridComplete: function() { 
            	/* 汇总功能 */
                if (toolGather != null && toolGather != "") {
                	var gathers = toolGather.split(",");
                    var gatheJson = "";
                    if (gathers.length > 0) {
                    	for (var j=0;j<gathers.length;j++) {
                    		for (var k=0;k<ccolumn.length;k++) {
                    			if (ccolumn[k] == gathers[j]) {
                    				var gatherJsonKey = ecolumn[k].name;
                    				var dataList = jQuery("#reportList").jqGrid('getCol',gatherJsonKey);
                    				gatheJson = gatheJson + gatherJsonKey + ":" + getTotleNum(dataList) + "," ;
                        		}
                    		}
                    	}
                    	gatheJson = "{" + gatheJson.substring(0,gatheJson.length-1) + "}";
                    	jQuery("#reportList").jqGrid('footerData','set', eval('(' + gatheJson + ')'));
                    }
                }
            }
        });
        jQuery("#reportList").jqGrid('navGrid','#reportPager',
            {edit:false,add:false,del:false},
            {},
            {},
            {},
            {multipleSearch:true, multipleGroup:false}
            );
        
        /* 二级表头 */
        if (groupFlag) {
        	jQuery("#reportList").jqGrid('setGroupHeaders', {
        		  useColSpanStyle: false, 
        		  groupHeaders:groupHeader	
        		}); 
        }
        
    }
    
    /* 取数组的和 */
    function getTotleNum(list) {
    	var sum = 0;
    	for (var i=0; i<list.length; i++) {
 			sum = sum + list[i] * 1;  		
    	}
    	return sum;
    }
    
   /* 保存sql */
   var sqlIds = "";
   function saveSql() {
       var timeSelect = $("#timeSelect  option:selected").text();
       var toolSqlName = $("#toolSqlName").val();
       $.ajax({
           type: "post", 
           url : "report/saveReportSql", 
           dataType:'json',
           data: {baseSql:$("#toolHSqlId").val(),
        	      timeSelect:timeSelect,
        		  sqlIds:sqlIds,
        		  sqlName:toolSqlName
           },
           success: function (data) {
               if(data.code == 0) {
	               sqlIds =  sqlIds.concat("\"" + timeSelect + "\"" + ":" + "\"" + data.data+ "\"").concat(" ,");
	               $("#saveReport").attr("disabled", false);
	               jAlert('保存SQL成功','提示');
               } else {
            	   jAlert(data.msg,'提示');
            	   return;
               }
           }
       });
   }
   
/* toolMiddle js */
    var funStr = "";
    var i = 1;
    var conArr = [];
    //增加按钮操作
    function addConShow () {
        $('#conShow').append("<div style='float:left;width:300px;' id='conShow"+i+"'></div>");
        $("#conShow"+i).append($("#conName").val());
        var conOption = getConOption();
        var conValueArry = "";
        if (conOption == 2 || conOption == 3) {
            conValueArry = getConValueByArry();
        }
        var conWhere = $('#conWhere').val();
        var obj = new Object();
        switch (conOption) {
        case 1:
        	$("#conShow"+i).append("<input type='text' style='width:150px;' name='"+conWhere+"'/>");
            if ($("#conType").val() == "日期") {
                $("input[name='"+conWhere+"']").datepicker();
            }
            obj.where = conWhere;
            obj.type = $("#conType").val();
            obj.name = $("#conName").val();
            obj.option = $("#conOption").val();
            obj.conValue = "";
            obj.conDefaultValue = $("#conDefaultValue").val();
            obj.orderNum = i;
            obj.rowNum = $("#conRowNum").val();
            conArr.push(obj);
            break;
        case 2:
        	if ($("#conType").val() == "模糊查询") {
	        	$("#conShow"+i).append("<div class='dynamicDiv'><input type='text' style='width:200px;' name='input"+conWhere+"'><ul class='dynamicUl' name='ul"+conWhere+"'></ul></div>");
	        	$("input[name='input" + conWhere + "']").attr("placeholder",conValueArry[0]);
	        	$("input[name='input" + conWhere + "']").focus(function(){
	        		if ($("input[name='input" + conWhere + "']").val() == "") {
	        			for(var i=0;i<conValueArry.length;i++){
	        				if (conValueArry[i].length >= 12) {
	        					$("ul[name='ul" + conWhere + "']").append("<li><a href=\"#\" style=\"color:black\" onclick=\"inDynamicName('"+conValueArry[i]+"','"+ conWhere +"')\">"+conValueArry[i].substring(0,10)+"...</a></li>");	
	        				} else
	        					$("ul[name='ul" + conWhere + "']").append("<li><a href=\"#\" style=\"color:black\" onclick=\"inDynamicName('"+conValueArry[i]+"','"+ conWhere +"')\">"+conValueArry[i]+"</a></li>");
	        			}
	        		}
	        		$("ul[name='ul" + conWhere + "']").show();
	        	});
	        	
	        	$("input[name='input" + conWhere + "']").bind('input propertychange', function() {
	        		var getconValueArry = $("input[name='input" + conWhere + "']").val(); 
	        		$("ul[name='ul" + conWhere + "']").html("");
	        		for(var i=0;i<conValueArry.length;i++){
	        			if (conValueArry[i] != null && conValueArry[i].indexOf(getconValueArry) > -1) {
	        				if (conValueArry[i].length >= 12) {
	        					$("ul[name='ul" + conWhere + "']").append("<li><a href=\"#\" style=\"color:black\" onclick=\"inDynamicName('"+conValueArry[i]+"','"+ conWhere +"')\">"+conValueArry[i].substring(0,10)+"...</a></li>");
	        				} else 
	        					$("ul[name='ul" + conWhere + "']").append("<li><a href=\"#\" style=\"color:black\" onclick=\"inDynamicName('"+conValueArry[i]+"','"+ conWhere +"')\">"+conValueArry[i]+"</a></li>");
	        			}
	        		}
	        	});
	        	obj.where = conWhere;
	            obj.type = $("#conType").val();
	            obj.name = $("#conName").val();
	            obj.option = $("#conOption").val();
	            obj.conValue = $("#conValue").val();
	            obj.conDefaultValue = $("#conDefaultValue").val();
	            obj.orderNum = i;
	            obj.rowNum = $("#conRowNum").val();
	            conArr.push(obj);
	        } else if ($("#conType").val() == "文本") {
	        	$("#conShow"+i).append("<select id='conValueSelect"+i+"' name='"+conWhere+"'></select>");
	            $.each(conValueArry, function(n, value){
	                $("#conValueSelect"+i).append("<option value='"+value+"'>"+value+"</option>");
	            });
	            obj.where = conWhere;
	            obj.type = $("#conType").val();
	            obj.name = $("#conName").val();
	            obj.option = $("#conOption").val();
	            obj.conValue = $("#conValue").val();
	            obj.conDefaultValue = $("#conDefaultValue").val();
	            obj.orderNum = i;
	            obj.rowNum = $("#conRowNum").val();
	            conArr.push(obj);
	        }
            
            break;
        case 3:
            $.each(conValueArry, function(n, value){
                $("#conShow"+i).append("<input type='checkbox' name='"+conWhere+"' value='"+value+"'>"+value+"</input>");
            });
            obj.where = conWhere;
            obj.type = $("#conType").val();
            obj.name = $("#conName").val();
            obj.option = $("#conOption").val();
            obj.conValue = $("#conValue").val();
            obj.conDefaultValue = $("#conDefaultValue").val();
            obj.orderNum = i;
            obj.rowNum = $("#conRowNum").val();
            conArr.push(obj);
            break;
        }
        
       $("#conShow"+i).append("<input type='button' value='移除' onclick='removeCon("+i+"," + JSON.stringify(obj) +")'/>");
    i++;
    }
    
    /* 获取操作条件，返回1,2,3等 */
    function getConOption() {
        var conOption = $("#conOption  option:selected").text();
        var returnCode = "";
        if (conOption == '表单(input)')  {
            returnCode = 1;
        }
        if (conOption == '单选(select)') {
            returnCode = 2;
        }
        if (conOption == '多选(checkbox)') {
            returnCode = 3;
        }
        return returnCode;
    }
    /* 替换逗号 */
    function replaceDot(str) {
        var oldValue = str;
        while(oldValue.indexOf("，") != -1)//寻找每一个中文逗号，并替换
        {
        str = oldValue.replace("，",",");
        oldValue = str;
        }
        return oldValue;
    }

   /* 获取条件值，并已数组形式返回，用于生成下拉列表，多选框 */
   function getConValueByArry() {
       var conValue = $("#conValue").val();
       if (conValue.indexOf("select") != -1) {
        $.ajax({ 
             type: "post", 
             url : "report/getConValue", 
             dataType:'json',
             async:false,
             data: {
            	 selectSql : conValue
             }, 
             success: function(data) {
	             if (data.code == 0) {
	                 conValue = data.data;
	             } else {
	                 jAlert(data.msg,'提示');
	                 return;
	             }
             }
           });
       } 
      conValue = replaceDot(conValue);
      var conValueArray = new Array();
      conValueArray = conValue.split(',');
      return conValueArray;
   }
   
   /* 移除按钮 */
   function removeCon (i, obj) {
       $("#conShow"+i).remove();
  	   conArr.splice($.inArray(obj,conArr),1);
   }
   
   /* 分情况得到选中的值 */
   function getConRealValu(conShowName) {
       if ($("input[name='"+conShowName+"']").attr("type") == "text") {
           return $("input[name='"+conShowName+"']").val();
       } else if ($("input[name='"+conShowName+"']").attr("type") == "checkbox") {
             var chk_value ="";    
              $("input[name='"+conShowName+"']:checked").each(function(){
                  chk_value += $(this).val()+",";    
                 });
             var rtchk_value = chk_value.substring(0,chk_value.length-1);
           return rtchk_value;
       } else {
           return $("select[name='"+conShowName+"'] option:selected").val();
       }
   }
   
   /* 下拉列表是否显示日期 */
   function  changeConType() {
        if ($("#conOption option:selected").text() != '表单(input)') {
            $("#conType").html("<option>文本</option><option>模糊查询</option>");
            $("#conValueTd").html("值<input id='conValue' type='text' size='10'/>");
            
        } else if ($("#conOption option:selected").text() == '表单(input)') {
            $("#conType").html("<option>文本</option><option>日期</option>");
            $("#conValueTd").html("");
        }
    }

   /* 初始化数据库列名 */
   function initToolEColumn(str) {
       var strmid = str.toLowerCase();
       var firstSelectIndex = getFirstSelectIndex(strmid);
       str = str.substring(firstSelectIndex);
       if(str.indexOf('from') != -1) {
           str = str.substring(0, str.indexOf('from'));
       }
       while (str.indexOf("(") != -1) {
           var removeStr = str.substring(str.indexOf("("), str.indexOf(")") + 1);
           if (removeStr.lastIndexOf("(") != -1) {
                removeStr = removeStr.substring(removeStr.lastIndexOf("("));
           }
           str = str.replace(removeStr, " ");
       }
       var arry = str.split(',');
       for (var i=0; i<arry.length; i++) {
         arry[i] = $.trim(arry[i]);
         if (arry[i].lastIndexOf(' ') != -1){
             arry[i] = arry[i].substring(arry[i].lastIndexOf(' ')+1, arry[i].length);
         }
       }
       return arry.toString();
       
   }

   /* sql中若有with等开头的情况下,找到第一个正确的select的位置 */
   function getFirstSelectIndex (baseSql) {
	   var firstWithIndex = baseSql.indexOf("with");
       var firstSelectIndex = baseSql.indexOf("select");
       /* 如果(和)在str中出现的次数不相等 */
       while (firstWithIndex !=-1 && firstWithIndex < firstSelectIndex && !isSameCnt(baseSql.substring(firstWithIndex, firstSelectIndex),"(",")")) {
           firstSelectIndex = baseSql.indexOf("select", firstSelectIndex+1);
           if (firstSelectIndex == -1) {
               return -1;
           }
       }
       return firstSelectIndex;
   }
   
   /* 判断两个字符a,b在一个字符串str中出现的次数是否相同 */
   function isSameCnt (str, a, b) {
	   var anum = getCharCnt(str, a);
       var bnum = getCharCnt(str, b);
       if (anum == bnum) {
           return true;
       }
       return false;
   }
   /* 得到某个字符在某个字符串中的个数 */
    function getCharCnt (str, targetStr) {
	   var cnt = 0;
	   for (var x=0; x<str.length; x++) {
		   if (str[x] == targetStr) {
			   cnt++;
		   }
	   }
	   return cnt;
   }
   
   
   /* bottom */
   var myChart;
   /* echarts图表初始化 */
   function imgInit() {
       
       require.config({
           paths: {
               'echarts': '${pageContext.request.contextPath}/js/echarts', //echarts.js的路径
               'echarts/chart/line' : '${pageContext.request.contextPath}/js/echarts', //echarts.js的路径
               'echarts/chart/bar' : '${pageContext.request.contextPath}/js/echarts',
               'echarts/chart/pie' : '${pageContext.request.contextPath}/js/echarts'
           }
       });
       require(
       [
           'echarts',
           'echarts/chart/line',
           'echarts/chart/bar',
           'echarts/chart/pie'
       ],
       //回调函数
       DrawEChart
       );
       //渲染ECharts图表
       
   }
    
    /* 图表回调函数 */
    function DrawEChart(ec) {
         /* 图表渲染的容器对象 */
         var chartContainer = document.getElementById("echart");
         /* 加载图表 */
         myChart = ec.init(chartContainer);
         myChart.setOption(barOption);
         /* 动态添加默认不显示的数据 */
         var ecConfig = require('echarts/config');
         myChart.on(ecConfig.EVENT.LEGEND_SELECTED, function (param){
             var selected = param.selected;
             changeLine(selected);
         });
    }
    
    function changeLine(selected) {
    	
    }
    function isJson(obj) {
	   	var isjson = typeof(obj) == "object" && Object.prototype.toString.call(obj).toLowerCase() == "[object object]" && !obj.length;    
	   	return isjson;
   	}
    
    /* 保存图标 */
    var chartOrder = 1;
    var saveReportCharts = [];
    function addChart () {
    	var saveReportChart = new Object();
    	saveReportChart.dataVsX = $("#columnVsX").val();
    	saveReportChart.dataVsLe = $("#columnVsLegend").val();
    	saveReportChart.chartOption = $("#chartOption").val();
    	saveReportChart.chartOrder = chartOrder;
    	saveReportChart.chartName = $("#chartName").val();
    	saveReportChart.chartType = $('input[name="chartType"]:checked').val();
        if (saveReportChart.dataVsX == "" || saveReportChart.dataVsLe == "" || saveReportChart.chartOption == "" || 
        		saveReportChart.chartOrder == "" || saveReportChart.chartName == "" || saveReportChart.chartType == "") {
        	jAlert("参数缺少","提示");
        	return;
        }
        saveReportCharts.push(saveReportChart);
        chartOrder ++;
        jAlert("添加报表" + saveReportChart.chartName + "成功","提示");
    }
    /* 展现图表 */
    function showChart() {
    	/* 图表初始化 */
        imgInit();
        var chartOption = $("#chartOption").val();
        var columnVsLegend = $("#columnVsLegend").val();
        var columnVsX = $("#columnVsX").val();
        var chartType = $('input[name="chartType"]:checked').val();
        /* columnVsLegend为空则根据表格自动生成 */
        var toolEColumns = $("#toolEColumn").val();
        var ccols = ccolumn;
        var ecols = toolEColumns.split(",");
        if (columnVsLegend == "") {
            
            for (var j = 1;j < ccols.length; j++) {
                columnVsLegend = columnVsLegend + ecols[j] + ":" + ccols[j] + ",";
            }
            columnVsLegend = columnVsLegend.substring(0,columnVsLegend.length-1);
        }
        
        /* columnVsX为空则根据表格自动生成 */
		if (columnVsX == "") {
			columnVsX = ecols[0] + ":" + ccols[0];
        }
        
        /* option为空则根据已有的柱状图option自动生成 */
        if (chartOption != "") {
        	if (isJson(chartOption)) {
        		barOption = chartOption;
            } else {
            	barOption = eval('(' + chartOption + ')');
            }
        }
        
        /* e.g tx_date:日期,result:结果,sumAmt:金额,sumcnt:笔数 */
        var columnVsLegends = columnVsLegend.split(",");
        
        var optionLegend = [];
        
        /* 若为第一次加载,series为空则拼接barOption.series和legend */
        if (barOption.series.length == 0) {
            $.each(columnVsLegends, function(n, value) {
                var strs = value.split(":");
                var serie = "{\"name\":\""+strs[1]+"\",\"type\":\"bar\",\"data\":[]}";
                serie = JSON.parse(serie);
                barOption.series.push(serie);
            });
        }
        
        
        
        /* barOption.series赋值 */
        $.each(columnVsLegends, function(n, value){
        	/* amt:金额,cnt:笔数,amt/cnt:测试除法 */
        	/* {"name":"笔数","type":"bar","data":[104,103]} */
            var strs = value.split(":");
            $.each(barOption.series, function(n, value) {
                if (value.name == strs[1]) {
                    var tempArr = jQuery("#reportList").jqGrid('getCol',strs[0]).reverse();
                    for (var i = 0; i<tempArr.length; i++) {
                        tempArr[i] = Number(tempArr[i]);
                    }
                    value.data = tempArr;
                    optionLegend.push(strs[1]);
                }
            });
        });
        /* X轴数据封装 */
        var xdatas = columnVsX.split(":");
        if (barOption.xAxis.length == 1) {
        	barOption.xAxis[0].data = jQuery("#reportList").jqGrid('getCol',xdatas[0]).reverse();
    	} else if (barOption.xAxis.length == 2) {
    		barOption.xAxis[0].data = jQuery("#reportList").jqGrid('getCol',xdatas[0]).reverse();
    		barOption.xAxis[1].data = jQuery("#reportList").jqGrid('getCol',xdatas[0]).reverse();
    	}
        barOption.legend.data = optionLegend;
        
        if (chartType == "bar") {
            $("#chartOption").val(JSON.stringify(barOption));
            $("#columnVsLegend").val(columnVsLegend);
            $("#columnVsX").val(columnVsX);
        }
        myChart.clear();
        myChart.setOption(barOption);
    }
    
    /* 迭代计算算法 */
    function jscalculate (param) {
    	
    }
    /* 基本计算处理 */
    function calculate(param1, param2, rule) {
    	var result = 0;
    	switch (rule) {
	        case "+":
	        	result = param1 + param2;
	            break;
	        case "-":
	        	result = param1 - param2;
	            break;
	        case "*":
	        	result = param1 * param2;
	            break;
	 		case "/":
	 			result = param1 / param2;
	            break;
        }
    	return result;
    }
    
    /* 柱状图option */
    barOption = {
            title : {
                text: '图标标题',
                subtext: '图标解释'
            },
            tooltip : {
                trigger: 'axis'
            },
            legend: {
                data:['结果','金额','笔数']
            },
            toolbox: {
                show : true,
                feature : {
                    mark : {show: true},
                    dataView : {show: true, readOnly: false},
                    magicType : {show: true, type: ['line', 'bar']},
                    restore : {show: true},
                    saveAsImage : {show: true}
                }
            },
            calculable : true,
            xAxis : [
                {
                    type : 'category',
                    data : ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月']
                },
                {
                    type : 'category',
                    axisLine: {show:false},
                    axisTick: {show:false},
                    axisLabel: {show:false},
                    splitArea: {show:false},
                    splitLine: {show:false},
                    data : ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月']
                }
            ],
            yAxis : [
                {
                    type : 'value'
                }
            ],
            series : []
        };

function saveReport() {
    var chartFlag = $('input[name="chartFlag"]:checked').val();
    $.ajax({
        url : "report/saveReport",
        type : "post",
        cache : false,
        dataType : "json",
        data:{
            saveReportFlag:$("#toolFlag").val(),
            saveReportTitle:$("#toolTitle").val(),
            saveReportCColumn:$("#toolCColumn").val(),
            saveReportEColumn:$("#toolEColumn").val(),
            saveReportSqlId:"{" + sqlIds.substring(0,sqlIds.length-1) + "}",
            saveReportToolGather:$("#toolGather").val(),
            saveReportFormatDatas : saveFormatDatas,
            
            saveReportCondition:JSON.stringify(conArr),
            
            saveChartFlag : chartFlag,
            saveReportChart : JSON.stringify(saveReportCharts)
            
            //saveReportChartOption:$("#chartOption").val(),
            //saveReportColumnVsLegend:$("#columnVsLegend").val()
        },
        success : function(rs) {
        	if (rs.code == 0) {
        		$("#mainContainer").html("保存报表成功");
        	} else {
        		jAlert(rs.msg,'提示');
        		return;
        	}
        },
        error : function(rs) {
        }
    });
}

$(function() {
    $("#content").css("width",$(window).width()*0.8);
    $("#content").css("height",$(window).height()*0.9);
    navgChange();
});
</script>


</head>


<body>
<div id="content">
<input type="button" value="保存报表" onclick="saveReport()" id="saveReport" disabled="disabled">
    <div id="toolHead" style="width:100%;height:40%;">
    公共信息
        <table>
           	<tr>
	            <td>数据库列名</td><td><input type="text" id="toolEColumn" size="30"/></td>
	            <td>报表标志</td><td><input type="text" id="toolFlag" size="10"/></td>
	            <td>标题</td><td><input type="text" id="toolTitle" size="10" /></td>
	            <td colspan="2"><input type="button" value="生成数据库列名" onclick="initEcolumn()"/></td>
	            <td></td><td></td>
	            <th rowspan="3">
	            	<textarea style="width:500px;height:80px;" id="toolHSqlId" ></textarea>
	            </th>
	            <td><input type="button" id="toolFind" value="查看" onclick="queryData()"/></td>
	            <td><input type="button" id="toolSave" value="保存" onclick="saveSql()"/></td>
            </tr>
            <tr>
	            <td>中文列名</td><td><input type="text" id="toolCColumn" size="30"/></td>
	            <td>汇总列</td><td><input type="text" id="toolGather" size="10" value=""/></td>
	            <td>sql名</td><td><input type="text" id="toolSqlName" size="10"/></td>
	            <td>时间维度</td><td><select id="timeSelect"><option>时</option><option>日</option><option>周</option><option>月</option><option>季</option><option>年</option></select></td>
	            <td></td><td></td><td></td>
	            <td></td><td></td><td></td>
            </tr>
            <tr>
	            <td>格式化列名</td><td><select id="columnName"><option>请先填写中文列名</option></select></td>
	            <td>格式化方式</td><td><select id="columnType"><option>正整数</option><option>小数</option><option>负数</option><option>百分比</option></select></td>
	            <td></td><td><input type="button" value="格式化" onclick="formatClick()"/></td>
	            <td></td><td></td>
	            <td></td><td></td><td></td>
	            <td></td><td></td><td></td>
            </tr>
        </table>
        
        <table id="reportList"></table>
        <div id="reportPager" ></div>
    </div>
    
    
    
    
    <div id="toolMiddle" style="width:100%;height:22%; margin-top: 40px;">
    条件
        <table id="ConTable">
            <tr><td>所属SQL条件</td><td><input type="text" id="conWhere" size="10"/></td>
            <td>第几行</td><td><select id="conRowNum"><option>1</option><option>2</option><option>3</option><option>4</option><option>5</option></select></td>
            <td>条件类型</td><td><select id="conType"><option>文本</option><option>日期</option><option>模糊查询</option></select></td>
            <td>条件名称</td><td><input type="text" id="conName" size="10"/></td>
            <td>相关值</td><td><input type="text" id="conDefaultValue" size="10"/></td>
            <td>选项</td><td><select id="conOption" onchange="changeConType()"><option value="input">表单(input)</option><option value="select">单选(select)</option><option value="checkbox">多选(checkbox)</option></select></td>
            <td></td><td id="conValueTd"></td>
            <td><input type="button" value="增加" id="conAdd" onclick="addConShow()"/></td>
        </table>
        <div style='width:100%' id="conShow"></div>
        
    </div>
    <div id="toolBottom" style="width:100%;height:30%;">
    图表&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" name="chartType" value="bar" checked="checked"/> 线状图/柱状图
        <input type="radio" name="chartType" value="pie" /> 饼图&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://echarts.baidu.com/doc/example.html" target="_blank">图表实例</a>
        <a href="http://echarts.baidu.com/doc/doc.html" target="_blank">图表doc</a>
        <br/>是否保存图形:
        <input type="radio" name="chartFlag" value="true" checked="checked"/> 是
        <input type="radio" name="chartFlag" value="false" /> 否
        <table id="chartTable">
            <tr>
                <td>图表名称</td><td><input type="text" id="chartName" size="10"/></td>
	            <td>图表Option</td><td><input type="text" id="chartOption" size="10"/></td>
	            <td>数据库列名与X轴对应关系</td><td><input type="text" id="columnVsX" size="20"/></td>
	            <td>数据库列名与legend对应关系</td><td><input type="text" id="columnVsLegend" size="30"/></td>
	            <td><input type="button" value="刷新图表" id="showChart" onclick="showChart()"/></td>
	            <td><input type="button" value="增加图表" id="addChart" onclick="addChart()"/></td>
	        </tr>
        </table>
        <div id="echart" style="height: 100%; width: 90%;"></div>
    </div>
</div>
</body>
