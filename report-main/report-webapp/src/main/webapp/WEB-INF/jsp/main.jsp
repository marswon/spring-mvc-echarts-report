<%@ page language="java" pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE HTML>
<html>
<head>
    <spring:url value="/ui/ui.jqgrid.css" var="jqgridCss"/>
    <link href="${jqgridCss}" rel="stylesheet"/>
    <title>报表</title>
    
    <title>report.com</title>
    <link href="${pageContext.request.contextPath}/ui/main.css" media="screen" rel="stylesheet" type="text/css" />
    <link href="${pageContext.request.contextPath}/ui/redmond/jquery-ui-1.9.2.custom.min.css"  rel="stylesheet"></link>
    <link href="${pageContext.request.contextPath}/ui/ui.jqgrid.css" rel="stylesheet"></link>
    <link href="${pageContext.request.contextPath}/ui/ui.multiselect.css" rel="stylesheet"></link>
    <link href="${pageContext.request.contextPath}/ui/zTreeStyle/zTreeStyle.css" rel="stylesheet"></link>
    <link href="${pageContext.request.contextPath}/ui/reveal.css" rel="stylesheet"></link>
    
    <script src="${pageContext.request.contextPath}/js/esl.js" type="text/javascript"></script>
    <script src="${pageContext.request.contextPath}/js/report-util.js" type="text/javascript"></script>
    <script src="${pageContext.request.contextPath}/js/jquery-1.9.0.min.js" type="text/javascript"></script>
    <script src="${pageContext.request.contextPath}/js/jquery-ui-1.9.2.custom.min.js" type="text/javascript"></script>
    <script src="${pageContext.request.contextPath}/js/jquery-migrate-1.2.1.js" type="text/javascript"></script>
    <script src="${pageContext.request.contextPath}/js/jquery.layout-latest.min.js" type="text/javascript"></script>
    <script src="${pageContext.request.contextPath}/js/i18n/grid.locale-cn.js" type="text/javascript"></script>
    <script src="${pageContext.request.contextPath}/js/i18n/jquery.ui.datepicker-zh-CN.js" type="text/javascript"></script>
    <script src="${pageContext.request.contextPath}/js/json2.js" type="text/javascript"></script>
    <script src="${pageContext.request.contextPath}/js/jquery.jqGrid.min.js" type="text/javascript"></script>
    <script src="${pageContext.request.contextPath}/js/jquery.ztree.all-3.5.js" type="text/javascript"></script>
    <script src="${pageContext.request.contextPath}/js/jquery.reveal.js" type="text/javascript"></script>
    
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/search/waypoints.min.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/search/waypoints-sticky.min.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/search/jquery.hideseek.min.js"></script>
    
    <link href="${pageContext.request.contextPath}/ui/jquery.alerts.css" media="screen" rel="stylesheet" type="text/css" />
	<script src="${pageContext.request.contextPath}/js/jquery.alerts.js" type="text/javascript"></script>
	
    
  </head>
  
  
<body class="report">
<div id="doc">
<div id="myModal" class="reveal-modal" style="width:375px;padding: 20px 20px 20px;">
			<div style="margin-top: 5px;">
                <label style="min-width:80px;display:inline-block;text-align:right;"></label>
                <span id="passWordWrong" style="color: red;"></span>
            </div>
            <div style="margin-top: 5px;">
                <label style="min-width:80px;display:inline-block;text-align:right;">原密码:</label>
                <input name="originPassword" id="originPassword" type="password"  style="width: 240px;height: 24px" />
            </div>
            <div style="margin-top: 5px;">
                <label style="min-width:80px;display:inline-block;text-align:right;">新密码:</label>
                <input name="newPassword" id="newPassword" type="password" style="width: 240px;height: 24px"/>
            </div><div style="margin-top: 5px;">
                <label style="min-width:80px;display:inline-block;text-align:right;">确认密码:</label>
                <input type="password" id="duplicatePassword" style="width: 240px;height: 24px"/>
            </div>
             <div style="margin-top: 5px;">
             <label style="min-width:80px;display:inline-block;text-align:right;"></label>
                <input type="button" onclick="changePassword()" value="保存"/>
            </div>
            
		<a class="close-reveal-modal">×</a>  

</div>
	<div class="hd">
		<!--/messages-->
		<div class="userHeader clearfix">
			<div class="fr" style="display:block;">
				<span class="tip">
				<c:if test="${hasPrevilege == 1}">
				<a style="font-size: 12px;color: antiquewhite;" href="${pageContext.request.contextPath}/toPermission.htm" target="_blank">权限管理</a>
				</c:if>
				<c:if test="${hasPrevilege != 1}">
				<a href="#" class="big-link" data-reveal-id="myModal"> 修改密码 </a>
				</c:if>
				</span>
				<span class="tip">${name}</span>
				<span class="tip">
				<a href="${pageContext.request.contextPath}/logout">安全退出</a>
				</span>
			</div>
			<div class="logo">
				<%-- <a href="javascript:"><img src="${pageContext.request.contextPath}/ui/images/hezi.jpg" style="width:122px;height:50px;"></a> --%>
			</div>
		</div>
		<div class="globalNav">
			<div class="bd2">
				<div class="leftCol js-app">
					<div class="search_Apps js-search-Apps" style="display:none" id="searchAppMain">
						<input type="text" style="border:none" id="search-highlight" name="search-highlight" placeholder="查找的报表名称" type="text" data-list=".highlight_list" autocomplete="off">
						<ul id="seselect" class="select-list js-select-list vertical highlight_list">
						</ul>
					</div>
					<div class="app-select js-app-select">
						<h4 class="select-head custom">
						<div class="selected js-selected">
						</div>
						<b class="icon pulldown"></b>
						</h4>
					</div>
					<ul id= "naselect" class="select-list js-select-list" style="display:none">
					</ul>
				</div>
				<div class="contentCol">
					<div class="topNav">
						<div class="navItem" id="hNav">
							<a href="javascript:" time="时">
							<span class="icon icons1"></span>
							<span>按小时</span>
							<span class="bot"></span>
							</a>
						</div>
						<div class="navItem currentItem" id="dNav">
							<a href="javascript:" time="日">
							<span class="icon icons1"></span>
							<span>按日</span>
							<span class="bot"></span>
							</a>
						</div>
						<div class="navItem " id="wNav">
							<a href="javascript:" time="周">
							<span class="icon icons1"></span>
							<span>按周</span>
							<span class="bot"></span>
							</a>
						</div>
						<div class="navItem " id="mNav">
							<a href="javascript:" time="月">
							<span class="icon icons1"></span>
							<span>按月</span>
							<span class="bot"></span>
							</a>
						</div>
						<div class="navItem " id="qNav">
							<a href="javascript:" time="季">
							<span class="icon icons1"></span>
							<span>按季</span>
							<span class="bot"></span>
							</a>
						</div>
						<div class="navItem " id="yNav">
							<a href="javascript:" time="年">
							<span class="icon icons1"></span>
							<span>按年</span>
							<span class="bot"></span>
							</a>
						</div>
					</div>
				</div>
			</div>
			<!-- user feedback icon -->
			
			<!-- feedback icon end -->
		</div>
	</div>
	<div class="bd clearfix">
		<div id="leftColContainer">
			<div class="leftCol">
				<div id="siderNav">
					<ul class="nav-items">
					</ul>
				</div>
			</div>
		</div>
		<div id="mainContainer">
		</div>
	</div>
</div>
</body>
<script>
var menuData = [];
var tempData = [];
var file = "";
var fileId = "";
var hsql = "";
var dsql = "";
var wsql = "";
var msql = "";
var qsql = "";
var ysql = "";
$.jgrid.no_legacy_api = true;
$.jgrid.useJSON = true;
function changePassword()
{
	var originPassword = $("#originPassword").val();
	var newPassword = $("#newPassword").val();
	var duplicatePassword = $("#duplicatePassword").val();
	if (newPassword != duplicatePassword) {
		$("#passWordWrong").html("两次输入的密码不一致");
		return;
	}
	
	$.ajax({
        url: '${pageContext.request.contextPath}/member/changePassword.htm',
        type: "POST",
        data:{
        	originPassword:originPassword,
        	newPassword:newPassword
        },
        cache:false,
        dataType: "json",
        success : function (result) {
			if (result.status == 1) {
				$("#myModal").trigger('reveal:close')
				jAlert('密码修改成功','提示');
				$("#originPassword").val("");
		    	$("#newPassword").val("");
		    	$("#duplicatePassword").val("");
			}
			else {
				$("#passWordWrong").html(result.errorInfo);
				return;
			}
        }
    });
}
function navgChange () {
	$("#" + fileId).css('color','white');
    $("#" + fileId).css('background-color','#5E5E5E');
}
function changPasswd () {
	$('#mainContainer').show();
}
$('.navigation').click(function(e){
    $.ajax({
        url: $(this).attr("fileName"),
        type: "GET",
        cache:false,
        dataType: "html",
        complete : function (req, err) {
        	hsql = "";
            dsql = "";
            wsql = "";
            msql = "";
            qsql = "";
            ysql = "";
            $('#mainContainer').show();
            $("#mainContainer").html(req.responseText);
        }
    });
  });
  
  $(".pulldown").click(function(e){
    e.stopPropagation();
    $("#naselect").css("display","block");
  });
  $(".js-selected").click(function(e){
        e.stopPropagation();
        $("#searchAppMain").css("display","block");
        $(".js-app-select").css("display","none");
        $("#naselect").css("display","none");
        $("#search-highlight").focus();
      });
  
  /* 展示左边列表 */
  function showSelect(modelId, menuId) {
	  $('.nav-items').empty();
	  var ldata = menuData.children;
	  for (var i=0; i<ldata.length; i++) {
		  if (modelId == ldata[i].id) {
			  $('.js-selected').html(ldata[i].text);
			  var lcdata = ldata[i].children;
			  for (var j=0; j<lcdata.length; j++) {
				  $('.nav-items').append("<li class=\"nav-item \"><span onclick=\"showFile(1," + lcdata[j].id + ")\"><a><b class=\"icon item-1\"></b>" + lcdata[j].text + "</a></span><ul class = \"sub-list\" id=\"" + lcdata[j].id + "\"></ul></li>");
			  }
		  }
	  }
	  if (menuId != "") {
		  showFile(3, menuId);
	  }
  }
  
  /* 根据r_id（父ID）和小时日周月标签去判断显示哪些子节点 */
  function showFile(status, r_id) {
      var time = $('.currentItem a').attr('time');
      var curNode = $('#'+r_id);
      if (curNode.parent().hasClass('on')&& status==1) {
          curNode.empty();
          curNode.css('display', 'none');
          curNode.parent().removeClass('on');
      } else if ((!curNode.parent().hasClass('on') && status==1) || (curNode.parent().hasClass('on')&& status==2) || status == 3) {
          curNode.empty();
          var ldata = menuData.children;
          for (var i=0; i<ldata.length; i++) {
        	  var lcdata = ldata[i].children;
        	  for (var j=0; j<lcdata.length; j++) {
        		  if (lcdata[j].id == r_id) {
                	  tempData = [];
                      tempText = [];
                      tempId = [];
                      showChildren(lcdata[j].children, time, true);
                      tempText.sort();
                      for (var k=0; k<=tempData.length-1; k++) {
                         var tempArr = tempData[k].split("&");
                         curNode.append("<li><a href=\"#\" style='' class='reportFile' id=\"" + tempArr[1] + "\" onclick=\"showReport('"+tempArr[0]+"','"+tempArr[1]+"')\">" + tempArr[2] + "</a></li>");
                      }
                      break;
                  }
        	  }
          }
          $('.nav-item').removeClass('on');
          $('.sub-list').css('display','none');
          curNode.css('display', 'block');
          curNode.parent().addClass('on');
      }
  }
  
  
  /* 展示报表 */
  function showReport(fileUrl, node) {
	    $(".reportFile").css('color','black');
	    $(".reportFile").css('background-color','white');
	    fileId = node;
	    
        file = fileUrl;
        $.ajax({
            url: fileUrl,
            type: "GET",
            cache:false,
            dataType: "html",
            complete : function (req, err) {
                file = fileUrl;
                $("#mainContainer").html(req.responseText);
				$('#mainContainer').show();
            }
        });
  }
  
  /* 展示子节点 */
  function showChildren (lcdata, time, flag) {
     for (var i=0;i<lcdata.length;i++) {
         if (lcdata[i].text.indexOf(time) != -1) {
             var chi = lcdata[i].children;
             if (chi.length != 0) {
                for (var j=0; j<chi.length; j++) {
                    tempData.push(chi[j].url + "&" + chi[j].id + "&" + chi[j].text);
                }
             } else {
            	 tempData.push(lcdata[i].url + "&" +lcdata[i].id + "&" + lcdata[i].text);
             }
         } else if (flag && lcdata[i].children.length == 0 && lcdata[i].text != "时报" && lcdata[i].text != "日报" && lcdata[i].text != "周报" 
        	 && lcdata[i].text != "月报" && lcdata[i].text != "季报" && lcdata[i].text != "年报") {
        	 tempData.push(lcdata[i].url + "&" + lcdata[i].id + "&" + lcdata[i].text);
         } else {
        	 showChildren (lcdata[i].children, time, false);
         }
     }
  }
  
  /* 展示点击的报表 */
  function searchClick (url, pid, node) {
	  showTime(pid, menuData.children);
      showReport(url, node);
  }
  
  /* 展现点击的报表的相应模块 */
  function showTime(pid,data) {
      for (var i =0;i<data.length;i++) {
          if (data[i].id != pid) {
              showTime(pid,data[i].children);
          } else {
        	  showSelect(data[i].pId, data[i].id);
        	  break;
          }
      }
  }
  
  function searchInit(data) {
     for (var i=0;i<data.length;i++) {
         if (data[i].url == null) {
             searchInit(data[i].children);
         } else {
             /* 添加子类 */
             $("#seselect").append("<li><a href='#' style=\"color:black\" onclick=\"searchClick('" + data[i].url + "','" + data[i].pId + "','"+data[i].id+"')\">"+data[i].text+"</a></li>");
         }
      }
  }
  
  /* 点击空白框时的事件 */
  $(document).click(function(e) {
      if ($(e.target).is('input#search-highlight'))
          $("#search-highlight").focus();
      else {
          $(".js-app-select").css("display","block");
          $("#naselect").css("display","none");
          $("#searchAppMain").css("display","none");
      }
  });
  
 /* 初始化 */
 $(function() {
        $('#search-highlight').hideseek({
            highlight: true
        });
	    $.ajax({
	            url: "menu/loadMenuByPriv.htm",
	            dataType: "json",
	            success : function (data) {
	            	menuData = data[0];
	            	//初始化模块下拉表
	            	var modelId = modelInit(menuData.children);
	            	//查找框置为空
	                $("#seselect").empty();
	                //展现商户报表
	                if (modelId != -1) {
	                	showSelect(modelId, "");
	                } else {
	                	showSelect(data[0].children[0].id, "");
	                }
	                //showSelect("商户报表",1);
	                //查找框初始化
	                searchInit(data);
	            }
	    });
	    
	    $('.topNav a').bind('click',function(e) {
	        $('.topNav .navItem').removeClass('currentItem');
	        var $this = $(this);
	        $this.parent().addClass('currentItem');
	        var ids = $('.on').children('span').attr('onclick');
	        if (ids!=undefined) {
	            var le = ids.indexOf(')')-ids.indexOf(',')-1;
	            showFile(2,ids.substr(ids.indexOf(',')+1,le));
	        }
            if (file != "") {
            	if (fileId != "") {
            		navgChange();
            	}
	        	showChangeReport(file);            
	        }
	    });
    

});

function topNavAClick () {
	$('.topNav a').bind('click',function(e) {
        $('.topNav .navItem').removeClass('currentItem');
        var $this = $(this);
        $this.parent().addClass('currentItem');
        var ids = $('.on').children('span').attr('onclick');
        if (ids!=undefined) {
            var le = ids.indexOf(')')-ids.indexOf(',')-1;
            showFile(2,ids.substr(ids.indexOf(',')+1,le));
        }
        if (file != "") {
        	if (fileId != "") {
        		navgChange();
        	}
        	showChangeReport(file);            
        }
    });
}
//初始化模块下拉表
function modelInit (data) {
	var fistModel = -1;
	for (var i=0; i<data.length; i++) {
		$("#naselect").append("<li name=\"\" onclick=\"showSelect('" + data[i].id + "','')\"> " + data[i].text + " </li >");
		if (i == data.length-1) {
			$('.js-selected').html(data[i].text);
			fistModel = data[i].id;
		}
	}
	return fistModel;
}
function topNavANotHave (nav,arg1) {
	$('#'+ nav +'Nav a').replaceWith("<p> <span class= \"icon icons1 \"></span> <span>" + arg1 + "</span> <span class=\"bot\"></span></p>");
    $('#'+ nav +'Nav span').css("color","gray");
}
function topNavAHave (nav,arg1,arg2) {
	$('#'+ nav +'Nav p').replaceWith("<a href=\"javascript:\" time=\""+arg1+"\"> <span class=\"icon icons1\"></span> <span>"+arg2+"</span> <span class=\"bot\"></span> </a>");
    $('#'+ nav +'Nav span').css("color","black");
}
function topNavInit (hsql,dsql,wsql,msql,qsql,ysql) {
	if (ysql == "") {
		topNavANotHave ('y','按年');
	} else {
		topNavAHave('y','年','按年');
		showSqlId = "y";
	}
	
	if (qsql == "") {
		topNavANotHave ('q','按季');
	} else {
		topNavAHave('q','季','按季');
		showSqlId = "q";
	}
	
	if (msql == "") {
		topNavANotHave ('m','按月');
	} else {
		topNavAHave('m','月','按月');
		showSqlId = "m";
	}
	
	if (wsql == "") {
		topNavANotHave ('w','按周');
	} else {
		topNavAHave('w','周','按周');
		showSqlId = "w";
	}
	
	if (dsql == "") {
		topNavANotHave ('d','按日');
	} else {
		topNavAHave('d','日','按日');
		showSqlId = "d";
	}
	
	if (hsql == "") {
		topNavANotHave ('h','按小时');
	} else {
		topNavAHave('h','时','按小时');
		showSqlId = "h";
	}
	if ($(".currentItem p").size() > 0) {
		$('.currentItem').removeClass('currentItem');
		$("#" + showSqlId + "Nav").addClass("currentItem");
	}
	topNavAClick();
}
</script>
  </html>
