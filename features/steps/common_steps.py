# -*- coding: utf-8 -*-
import json

from behave import *

from features.util import bdd_util
from features.util.helper import WAIT_SHORT_TIME
from db.account import models as account_models

from features.steps import weapp_steps 

@given(u"{user}获得访问'{webapp_owner_name}'数据的授权")
def step_impl(context, user, webapp_owner_name):
	#进行登录，并获取context.client.user, context.client.woid
	weapp_steps._run_weapp_step(u'When %s关注%s的公众号' % (user, webapp_owner_name), None)
	weapp_steps._run_weapp_step(u'When %s访问%s的webapp' % (user, webapp_owner_name), None)

	bdd_util.login(user, None, context=context)

	webapp_owner = account_models.User.get(username=webapp_owner_name)
	user = account_models.User.get(username=mp_user_name)
	profile = account_models.UserProfile.get(user=user.id)

	context.client.woid = webapp_owner.id
	context.webapp_owner_id = weapp_owner.id
	context.webapp_user = user
	context.webapp_id = profile.webapp_id
	

@then(u"{user}获得错误提示'{error}'")
def step_impl(context, user, error):
	context.tc.assertEquals(error, context.server_error_msg)

@then(u"{user}获得'{product_name}'错误提示'{error}'")
def step_impl(context, user, product_name ,error):
	detail = context.response_json['data']['detail']
	context.tc.assertEquals(error, detail[0]['short_msg'])
	pro_id = ProductFactory(name=product_name).id
	context.tc.assertEquals(pro_id, detail[0]['id'])

@when(u"{user}关注{mp_user_name}的公众号")
def step_impl(context, user, mp_user_name):
	weapp_steps._run_weapp_step(u'When %s关注%s的公众号' % (user, mp_user_name), None)

@given(u"{user}关注{mp_user_name}的公众号")
def step_impl(context, user, mp_user_name):
	weapp_steps._run_weapp_step(u'Given %s关注%s的公众号' % (user, mp_user_name), None)

@when(u"{user}访问{mp_user_name}的webapp")
def step_impl(context, user, mp_user_name):
	weapp_steps._run_weapp_step(u'When %s访问%s的webapp' % (user, mp_user_name), None)

	user = account_models.User.get(username=mp_user_name)
	profile = account_models.UserProfile.get(user=user.id)
	bdd_util.login(user, None, context=context)
	
	context.webapp_owner_id = user.id
	context.client.woid = context.webapp_owner_id
	context.webapp_user = user
	context.webapp_id = profile.webapp_id

