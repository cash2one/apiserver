# -*- coding: utf-8 -*-
from eaglet.core.service.celery import task

from db.mall import models as mall_models


@task(bind=True)
def record_order_status_log(self, order_id, operator, from_status, to_status):
    """
    创建订单状态日志
    """

    order_status_log = mall_models.OrderStatusLog.create(
            order_id=order_id,
            from_status=from_status,
            to_status=to_status,
            operator=operator
    )
