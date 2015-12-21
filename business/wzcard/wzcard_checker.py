#coding: utf8
import logging


class WZCardChecker(object):
	"""
	判断微众卡能否使用
	"""

	def __init__(self):
		self.checked_wzcard = dict()

	def check(self, wzcard_id, password, wzcard):
		"""
		检查微众卡是否可用

		@see `wezoom_card/module_api.py`中的`check_weizoom_card`
		"""
		if wzcard_id in self.checked_wzcard:
			reason = u'该微众卡已经添加'
			logging.error("{}, wzcard: {}".format(reason, wzcard))
			return False, {
				"is_success": False,
				"type": 'wzcard:duplicated',
				"msg": reason,
				"short_msg": u'已添加'
			}

		self.checked_wzcard[wzcard_id] = wzcard

		if not wzcard:
			# 无此微众卡
			reason = u'无此微众卡'
			logging.error("{}, wzcard: {}".format(reason, wzcard))
			return False, {
				"is_success": False,
				"type": 'wzcard:nosuch',
				"msg": reason,
				"short_msg": u'无此卡'
			}
		elif not wzcard.check_password(password):
			# 密码错误
			reason = u'卡号或密码错误'
			logging.error("{}, wzcard: {}".format(reason, wzcard))
			return False, {
				"is_success": False,
				"type": 'wzcard:wrongpass',
				"msg": reason,
				"short_msg": u'密码错误'
			}
		elif wzcard.is_expired:
			# 密码错误
			reason = u'微众卡已过期'
			logging.error("{}, wzcard: {}".format(reason, wzcard))
			return False, {
				"is_success": False,
				"type": 'wzcard:expired',
				"msg": reason,
				"short_msg": u'微众卡已过期'
			}
		elif not wzcard.is_activated:
			reason = u'微众卡未激活'
			logging.error("{}, wzcard: {}".format(reason, wzcard))	
			return False, {
				"is_success": False,
				"type": 'wzcard:inactive',
				"msg": reason,
				"short_msg": u'卡未激活'
			}
		return True, {}
