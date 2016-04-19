# -*- coding: utf-8 -*-
"""
@package wapi.mall.a_news_page
图文页面api
"""

from core import api_resource
from core.exceptionutil import unicode_full_stack
from wapi.decorators import param_required
from business.news.news_page import NewsPage
from business.mall.order_config import OrderConfig
from business.account.member import Member


class ANewsPage(api_resource.ApiResource):
    """
    图文页面
    """
    app = 'news'
    resource = 'news_page'

    @param_required(['news_id'])
    def get(args):
        webapp_user = args['webapp_user']
        webapp_owner = args['webapp_owner']

        news = NewsPage.from_id({
                'webapp_owner': args['webapp_owner'],
                'webapp_user': args['webapp_user'],
                'news_id': args['news_id']
            })

        member_info = Member.from_id({
                'webapp_owner': 'webapp_owner',
                'member_id': webapp_user.id
            })
        order_config = OrderConfig.get_order_config({'webapp_owner': webapp_owner})

        share_info = {
            'share_img_url': order_config['share_image'],
            'share_page_desc': order_config['share_describe']
        }

        return {
            'news': news,
            'share_info': share_info,
            'member_nick_name': member_info['username_hexstr'] if member_info else None
        }