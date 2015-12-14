# -*- coding: utf-8 -*-

"""@package business.mall.postage_calculator
运费计算器

算法：

 1. 计算统一运费商品的运费
 2. 剩下的商品使用系统运费模板
"""

from db.mall import models as mall_models


class PostageCalculator(object):
	def __init__(self, postage_config):
		self.postage_config = postage_config

	def __is_satisfy_free_postage_condition(self, products, province_id):
		"""
		判断是否符合包邮条件
		"""
		total_price = 0.0
		total_ount = 0
		for product in products:
			total_price += product.original_price * product.purchase_count
			total_ount += product.purchase_count

		#包邮条件
		if self.postage_config['factor']['free_factor']:
			free_factors = self.postage_config['factor']['free_factor'].get(province_id, None)
			if free_factors:
				for free_factor in free_factors:
					#满钱数包邮
					if free_factor['condition'] == "money" and free_factor['condition_value'] <= total_price:
						return True

					#满件数包邮
					if free_factor['condition'] == "count" and free_factor['condition_value'] <= total_ount:
						return True

		return False

	def __get_postage_for_weight(self, weight, factor):
		"""
		计算weight在使用postage factor时的运费
		"""
		if weight == 0:
			return 0.0

		if weight <= factor['firstWeight']:
			return factor['firstWeightPrice']

		weight = weight - factor['firstWeight'] #首重
		price = factor['firstWeightPrice'] #首重价格
		added_weight = factor['addedWeight'] #续重

		#TODO: 浮点等值判断改进
		if added_weight == 0.0:
			return price

		added_count = 1
		while True:
			weight = weight - added_weight
			if weight <= 0:
				break
			else:
				added_count += 1
		added_price = added_count * factor['addedWeightPrice']
		return price + added_price

	def __get_province_id_by_area(self, area):
	    """
	    根据area：2_2_22 , 来获取省份id(2)
	    """
	    if area and len(area.split('_')):
	        return area.split('_')[0]
	    return 0

	def get_postage(self, order):
		"""
		计算运费
		"""
		products = order.products
		ship_area = order.purchase_info.ship_info['area']

		province_id = self.__get_province_id_by_area(ship_area)

		unified_postage_money = 0.0
		unified_postage_money_id = []
		postage_template_money = 0.0
		products_use_template = []
		weight = 0.0
		province_id = 'province_%s' % province_id
		for product in products:
			if product.postage_type == mall_models.POSTAGE_TYPE_UNIFIED:
				#商品使用统一运费
				if product.id not in unified_postage_money_id:
					unified_postage_money += product.unified_postage_money
					unified_postage_money_id.append(product.id)
			else:
				#商品使用运费模板
				products_use_template.append(product)
				weight += product.weight * product.purchase_count

		if (len(products_use_template) > 0) and (not self.__is_satisfy_free_postage_condition(products_use_template, province_id)):
			special_postage_factor = self.postage_config['factor']['special_factor'].get(province_id, None)
			if special_postage_factor:
				postage_template_money = self.__get_postage_for_weight(weight, special_postage_factor)
			else:
				postage_template_money = self.__get_postage_for_weight(weight, self.postage_config['factor'])

		return unified_postage_money + postage_template_money