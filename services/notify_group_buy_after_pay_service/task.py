# # -*- coding: utf-8 -*-
#
# import db.account.models as accout_models
# from db.mall import models as mall_models
# from db.mall import promotion_models
# from eaglet.core.service.celery import task
#
# import settings
# from core.exceptionutil import unicode_full_stack
# from core.sendmail import sendmail
# from eaglet.core import watchdog
# from features.util.bdd_util import set_bdd_mock
# from util.microservice_consumer import microservice_consume
#
#
# @task(bind=True)
# def notify_group_buy_after_pay(self, url, data):
#     """
#     团购订单支付后通知团购服务
#     """
#     microservice_consume(url=url, data=data, method='put')
