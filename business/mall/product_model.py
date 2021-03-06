# -*- coding: utf-8 -*-
"""@package business.mall.product_model
商品规格
"""

import json
from bs4 import BeautifulSoup
import math
from datetime import datetime

from eaglet.decorator import param_required
#from wapi import wapi_utils
from eaglet.core.cache import utils as cache_util
from db.mall import models as mall_models
from db.mall import promotion_models
from eaglet.core import watchdog
from business import model as business_model
import settings


class ProductModel(business_model.Model):
	"""
	商品
	"""
	__slots__ = (
		'id',
		'is_deleted',
		'product_id',
		'name',
		'weight',
		'price',
		'purchase_price',
		'original_price',
		'market_price',
		'user_code',
		'stock_type',
		'stocks',

		'property_values',
		'property2value'
	)

	def __init__(self, db_model=None, id2property=None, id2propertyvalue=None, corp_id=None):
		business_model.Model.__init__(self)

		if db_model:
			self._init_slot_from_model(db_model)
			# if db_model.name == 'standard':
			self.original_price = db_model.price
			# 社群改价,单规格original_price展示供货价
			self.price = self.community_model_price(corp_id)
			# else:
			# 	self.original_price = self.community_model_price(corp_id)
			# 	# 多规格颠倒过来
			# 	self.price = db_model.price
			
			self.stocks = db_model.stocks if db_model.stock_type == mall_models.PRODUCT_STOCK_TYPE_LIMIT else u'无限'

			self.__fill_model_property_info(id2property, id2propertyvalue)

	def __fill_model_property_info(self, id2property, id2propertyvalue):
		'''
		获取model关联的property信息
			model.property_values = [{
				'propertyId': 1,
				'propertyName': '颜色',
				'id': 1,
				'value': '红'
			}, {
				'propertyId': 2,
				'propertyName': '尺寸',
				'id': 3,
				'value': 'S'
			}]

			model.property2value = {
				'颜色': '红',
				'尺寸': 'S'
			}
		'''
		if not id2property:
			return

		if self.name == 'standard':
			self.property2value = None
			self.property_values = None
			return

		#商品规格名的格式为${property1_id}:${value1_id}_${property2_id}:${value2_id}
		ids = self.name.split('_')
		property_values = []
		property2value = {}
		for id in ids:
			# id的格式为${property_id}:${value_id}
			_property_id, _value_id = id.split(':')
			_property = id2property[_property_id]
			_value = id2propertyvalue[id]
			property2value[_property['name']] = {
				'id': _value['id'],
				'name': _value['name']
			}
			a_image = _value['image'] if _value['image'] else ''
			property_values.append({
				'propertyId': _property['id'],
				'propertyName': _property['name'],
				'id': _value['id'],
				'name': _value['name'],
				'image': '%s%s' % (settings.IMAGE_HOST, a_image) if a_image and a_image.find('http') == -1 else a_image
			})

		self.property_values = property_values
		self.property2value = property2value
		
	def community_model_price(self, corp_id):
		"""
		社群修改商品某个规格的改价
		"""
		
		price_model = mall_models.ProductCustomizedPrice.select()\
			.dj_where(corp_id=corp_id, product_id=self.product_id, product_model_id=self.id).first()
		return price_model.price if price_model else self.price
