# -*- coding: utf-8 -*-
"""@package business.spread.MemberRelation
会员
"""

#import json
#from bs4 import BeautifulSoup
#import math
#from datetime import datetime

#from eaglet.decorator import param_required
##from wapi import wapi_utils
#from cache import utils as cache_util
#from api.mall import models as mall_models
#from api.mall import promotion_models
from db.member import models as member_models
#import resource
#from eaglet.core import watchdog
from business import model as business_model
#import settings
from business.decorator import cached_context_property
from util import emojicons_util

class MemberSharedUrl(business_model.Model):
	"""
	会员关系
	"""
	__slots__ = (
	)

	# @staticmethod
	# def from_models(query):
	# 	pass

	# @staticmethod
	# def from_model(webapp_owner, model):
	# 	member = Member(webapp_owner, model)
	# 	member._init_slot_from_model(model)

	# 	return member

	# @staticmethod
	# def from_id(member_id, webapp_owner):
	# 	try:
	# 		member_db_model = member_models.Member.get(id=member_id)
	# 		return Member.from_model(member_db_model, webapp_owner)
	# 	except:
	# 		return None

	def __init__(self, member_id, follower_member_id):
		business_model.Model.__init__(self)

	@staticmethod
	def validate(member_id, shared_url_digest):
		return member_models.MemberSharedUrlInfo.select().dj_where(member_id=member_id, shared_url_digest=shared_url_digest).count() == 0

	@staticmethod
	def empty_member_shared_info():
		"""工厂方法，创建空的MemberSharedUrlInfo对象

		@return MemberSharedUrlInfo
		"""
		member_shared_url_info = MemberSharedUrlInfo(None, None)
		return member_shared_url_info

