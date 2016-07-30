package com.sypay.omp.per.dao;

import java.util.List;
import java.util.Map;
import java.util.Set;

import com.sypay.omp.per.domain.Role;
import com.sypay.omp.per.model.RoleCell;
import com.sypay.omp.per.model.RoleCriteriaModel;
import com.sypay.omp.per.model.RoleListSysModel;
import com.sypay.omp.per.model.RoleModel;
import com.sypay.omp.per.model.page.PageHelper;


public interface RoleDao {
	List<Role> findRoles();

	List<Map<String, String>> findRoleNamesByGroupCode(String groupCode);
	
	List<RoleListSysModel> getRoleListBySysCodes(Set<String> sysCodes);
	
	void clearMiddleTableData(Long id);
	
	boolean isRoleCodeExists(RoleModel roleModel);
	
	List getRoleListByGroupCode(String groupCode);
	
	List<Map<String, Object>> getRoleCodeAndNameList(String groupCode);

	List<String> findSysCodeByRoleCodes(List<String> roleCodes);

	// 角色管理页面中要显示给系统管理员的数据
	List<RoleModel> findRoleListByCriteria(PageHelper pageHelper, RoleCriteriaModel roleCriteriaModel);

	Long countRoleByCriteria(RoleCriteriaModel roleCriteriaModel);

	List<Role> findCurrentSysRolesBySysCode(String sysCode);

	boolean isSameRoleCode(Long roleId, String roleCode);

	// 查询会员所有角色
	List<Role> findAllRoles(Long memberId);

    RoleCell getByRoleCode(String roleCode);

    List<String> findRoleCodeByMemberId(Long memberId);
}
