# watcher: tianfengmin@weizoom.com, benchi@weizoom.com#
# __author__ : "田丰敏" 2016-05-25

Feature: 增加对供货商的留言框
"""
备注：
[前台]
	1、编辑订单页面增加供货商店铺，并显示其所属的所有商品，增加对供货商的留言框
	2、留言框限制在45字以内
	3、订单详情页按供货商分组展示，可查看到留言信息，留言信息显示在商品信息和物流信息中间，如果没有留言则不显示
	4、一个供货商的商品，订单详情页留言部分按照原来的样式展示
[后台]
	1、买家信息提示弹窗（灰色叹号弹窗）中，去掉买家留言
	2、保留黄色留言弹框，鼠标放在黄色图标，可显示供货商名称和买家留言信息

	自营平台:
		1、在黄色留言弹框中显示买家留言信息，显示供货商名和留言信息，格式可参考样图
		2、订单详情页中买家留言按照供货商显示，显示供货商名和留言信息，格式可参考样图

	供货商同步订单:
		1、同步子订单的对应留言显示在本店的对应位置，不显示供货商名称，只显示买家留言

"""

Background:
	#自营平台jobs的信息
		Given 重置'weapp'的bdd环境
		Given 设置jobs为自营平台账号::weapp
		Given jobs登录系统::weapp
		And jobs已添加供货商::weapp
			"""
			[{
				"name": "供货商1",
				"responsible_person": "宝宝",
				"supplier_tel": "13811223344",
				"supplier_address": "北京市海淀区泰兴大厦",
				"remark": "备注卖花生油"
			}, {
				"name": "供货商2",
				"responsible_person": "陌陌",
				"supplier_tel": "13811223344",
				"supplier_address": "北京市海淀区泰兴大厦",
				"remark": ""
			}]
			"""
		And jobs已添加支付方式::weapp
			"""
			[{
				"type": "微信支付",
				"is_active": "启用"
			}, {
				"type": "支付宝",
				"is_active": "启用"
			}, {
				"type": "货到付款",
				"is_active": "启用"
			}]
			"""
		And jobs已添加商品::weapp
			"""
			[{
				"supplier": "供货商1",
				"name": "商品1a",
				"price": 10.00,
				"purchase_price": 9.00,
				"weight": 1.0,
				"stock_type": "无限",
				"pay_interfaces":[{
					"type": "货到付款"
				}]
			}, {
				"supplier": "供货商1",
				"name": "商品1b",
				"price": 20.00,
				"purchase_price": 19.00,
				"weight": 1.0,
				"stock_type": "有限",
				"stocks": 10,
				"pay_interfaces":[{
					"type": "货到付款"
				}]
			}, {
				"supplier": "供货商2",
				"name": "商品2a",
				"price": 20.00,
				"purchase_price": 19.00,
				"weight": 1.0,
				"stock_type": "有限",
				"stocks": 10,
				"pay_interfaces":[{
					"type": "货到付款"
				}]
			}]
			"""
	#商家bill的信息
		Given 添加bill店铺名称为'bill商家'::weapp
		Given bill登录系统::weapp
		And bill已添加支付方式::weapp
			"""
			[{
				"type": "微信支付",
				"is_active": "启用"
			}]
			"""
		And bill已添加商品::weapp
			"""
			[{
				"name":"bill商品1",
				"created_at": "2016-05-20",
				"model": {
					"models": {
						"standard": {
							"price": 10.00,
							"user_code":"0101",
							"weight":1.0,
							"stock_type": "无限"
						}
					}
				}
			},{
				"name":"bill商品2",
				"created_at": "2016-05-21",
				"model": {
					"models": {
						"standard": {
							"price": 20.00,
							"user_code":"0102",
							"weight":1.0,
							"stock_type": "无限"
						}
					}
				}
			}]
			"""

	#商家tom的信息
		Given 添加tom店铺名称为'tom商家'::weapp
		Given tom登录系统::weapp
		And tom已添加支付方式::weapp
			"""
			[{
				"type": "微信支付",
				"is_active": "启用"
			}]
			"""
		And tom已添加商品::weapp
			"""
			[{
				"name":"tom商品1",
				"created_at": "2016-05-22",
				"is_member_product":"off",
				"model": {
					"models": {
						"standard": {
							"price": 10.00,
							"user_code":"0201",
							"weight":1.0,
							"stock_type": "无限"
						}
					}
				},
				"status":"在售"
			},{
				"name":"tom商品2",
				"created_at":"2016-05-23",
				"is_member_product":"off",
				"model": {
					"models": {
						"standard": {
							"price": 20.00,
							"user_code":"0202",
							"weight":1.0,
							"stock_type": "有限",
							"stocks":200
						}
					}
				},
				"status":"在售"
			}]
			"""
	#jobs后台商品信息
		Given jobs登录系统::weapp
		Then jobs获得商品池商品列表::weapp
			"""
			[{
				"name": "tom商品2",
				"user_code":"0202",
				"supplier":"tom商家",
				"price": 20.00,
				"stocks":200,
				"status":"未选择",
				"sync_time":"",
				"actions": ["放入待售"]
			},{
				"name": "tom商品1",
				"user_code":"0201",
				"supplier":"tom商家",
				"price": 10.00,
				"stocks":"无限",
				"status":"未选择",
				"sync_time":"",
				"actions": ["放入待售"]
			},{
				"name": "bill商品2",
				"user_code":"0102",
				"supplier":"bill商家",
				"price": 20.00,
				"stocks": "无限",
				"status":"未选择",
				"sync_time":"",
				"actions": ["放入待售"]
			},{
				"name": "bill商品1",
				"user_code":"0101",
				"supplier":"bill商家",
				"price": 10.00,
				"stocks": "无限",
				"status":"未选择",
				"sync_time":"",
				"actions": ["放入待售"]
			}]
			"""
		When jobs将商品池商品批量放入待售于'2016-05-24 10:30'::weapp
			"""
			[
				"tom商品2",
				"tom商品1",
				"bill商品2",
				"bill商品1"
			]
			"""

		#jobs修改采购价
		When jobs更新商品'bill商品1'::weapp
			"""
			{
				"name":"bill商品1",
				"supplier":"bill商家",
				"purchase_price": 9.00,
				"is_member_product":"off",
				"model": {
					"models": {
						"standard": {
							"price": 10.00,
							"user_code":"0101",
							"weight":1.0,
							"stock_type": "无限"
						}
					}
				}
			}
			"""
		When jobs更新商品'bill商品2'::weapp
			"""
			{
				"name":"bill商品2",
				"supplier":"bill商家",
				"purchase_price": 19.00,
				"is_member_product":"off",
				"model": {
					"models": {
						"standard": {
							"price": 20.00,
							"user_code":"0102",
							"weight":1.0,
							"stock_type": "无限"
						}
					}
				}
			}
			"""
		When jobs更新商品'tom商品1'::weapp
			"""
			{
				"name":"tom商品1",
				"supplier":"tom商家",
				"purchase_price": 9.00,
				"is_member_product":"off",
				"model": {
					"models": {
						"standard": {
							"price": 10.00,
							"user_code":"0201",
							"weight":1.0,
							"stock_type": "无限"
						}
					}
				}
			}
			"""
		When jobs更新商品'tom商品2'::weapp
			"""
			{
				"name":"tom商品2",
				"supplier":"tom商家",
				"purchase_price": 19.00,
				"is_member_product":"off",
				"model": {
					"models": {
						"standard": {
							"price": 20.00,
							"user_code":"0202",
							"weight":1.0,
							"stock_type": "无限"
						}
					}
				}
			}
			"""
		When jobs批量上架商品::weapp
			"""
			["bill商品1","bill商品2","tom商品1","tom商品2"]
			"""
	#tom1关注自营平台公众号
		When tom1关注jobs的公众号

@mall3 @eugene
Scenario:1 手机端验证
	#购买自营平台自建商品,订单不同步到商家[供货商1、供货商2]
	#待发货-001(商品1a,1、商品1b,1、商品2a,1)微信支付
		When tom1访问jobs的webapp
		And tom1加入jobs的商品到购物车
			"""
			[{
				"name": "商品1a",
				"count": 1
			}, {
				"name": "商品1b",
				"count": 1
			},{
				"name": "商品2a",
				"count": 1
			}]
			"""
		When tom1从购物车发起购买操作
			"""
			{
				"action": "pay",
				"context": [{
					"name": "商品1a"
				}, {
					"name": "商品1b"
				}, {
					"name": "商品2a"
				}]
			}
			"""
		And tom1在购物车订单编辑中点击提交订单
			"""
			{
				"ship_name": "AAA",
				"ship_tel": "13811223344",
				"ship_area": "北京市 北京市 海淀区",
				"ship_address": "泰兴大厦",
				"pay_type": "微信支付",
				"order_id": "001",
				"customer_message": {
					"供货商1":"供货商1订单001备注",
					"供货商2":"供货商2订单001备注"
				}
			}
			"""
		Then tom1成功创建订单
			"""
			{
				"order_id": "001",
				"status": "待支付",
				"ship_name": "AAA",
				"ship_tel": "13811223344",
				"ship_area": "北京市 北京市 海淀区",
				"ship_address": "泰兴大厦",
				"final_price": 50.00,
				"products": [{
					"name": "商品1a",
					"price": 10.00,
					"count": 1,
					"supplier": "供货商1"
				}, {
					"name": "商品1b",
					"price": 20.00,
					"count": 1,
					"supplier": "供货商1"
				},{
					"name": "商品2a",
					"price": 20.00,
					"count": 1,
					"supplier": "供货商2"
				}],
				"customer_message":{
					"供货商1":"供货商1订单001备注",
					"供货商2":"供货商2订单001备注"
				}
			}
			"""

	#购买商家同步商品（单个供货商）订单同步到商家后台[bill商家]
	#待发货-002(bill商品1,1、bill商品2,1),有留言,微信支付
		When tom1访问jobs的webapp
		And tom1加入jobs的商品到购物车
			"""
			[{
				"name": "bill商品1",
				"count": 1
			}, {
				"name": "bill商品2",
				"count": 1
			}]
			"""
		When tom1从购物车发起购买操作
			"""
			{
				"action": "pay",
				"context": [{
					"name": "bill商品1"
				}, {
					"name": "bill商品2"
				}]
			}
			"""
		And tom1在购物车订单编辑中点击提交订单
			"""
			{
				"ship_name": "AAA",
				"ship_tel": "13811223344",
				"ship_area": "北京市 北京市 海淀区",
				"ship_address": "泰兴大厦",
				"pay_type": "微信支付",
				"order_id": "002",
				"customer_message":{
					"bill商家": "bill商家订单002备注"
				}
			}
			"""
		When tom1使用支付方式'微信支付'进行支付订单'002'
		Then tom1成功创建订单
			"""
			{
				"order_id": "002",
				"status": "待发货",
				"ship_name": "AAA",
				"ship_tel": "13811223344",
				"ship_area": "北京市 北京市 海淀区",
				"ship_address": "泰兴大厦",
				"final_price": 30.00,
				"products": [{
					"name": "bill商品1",
					"price": 10.00,
					"count": 1,
					"supplier": "bill商家"
				}, {
					"name": "bill商品2",
					"price": 20.00,
					"count": 1,
					"supplier": "bill商家"
				}],
				"customer_message": {
					"bill商家":"bill商家订单002备注"
				}
			}
			"""


	#购买商家同步商品（多个供货商）订单同步到商家后台[bill商家、tom商家]
	#待发货-003(bill商品1,1、tom商品1,1),多个供货商均有留言,货到付款
		When tom1访问jobs的webapp
		And tom1加入jobs的商品到购物车
			"""
			[{
				"name": "bill商品1",
				"count": 1
			}, {
				"name": "tom商品1",
				"count": 1
			}]
			"""
		When tom1从购物车发起购买操作
			"""
			{
				"action": "pay",
				"context": [{
					"name": "bill商品1"
				}, {
					"name": "tom商品1"
				}]
			}
			"""
		And tom1在购物车订单编辑中点击提交订单
			"""
			{
				"ship_name": "AAA",
				"ship_tel": "13811223344",
				"ship_area": "北京市 北京市 海淀区",
				"ship_address": "泰兴大厦",
				"pay_type": "货到付款",
				"order_id": "003",
				"customer_message":{
					"bill商家":"bill商家订单003备注",
					"tom商家":"tom商家订单003备注"
				}
			}
			"""
		Then tom1成功创建订单
			"""
			{
				"order_id": "003",
				"status": "待发货",
				"ship_name": "AAA",
				"ship_tel": "13811223344",
				"ship_area": "北京市 北京市 海淀区",
				"ship_address": "泰兴大厦",
				"final_price": 20.00,
				"products": [{
					"name": "bill商品1",
					"price": 10.00,
					"count": 1,
					"supplier": "bill商家"
				},{
					"name": "tom商品1",
					"price": 10.00,
					"count": 1,
					"supplier": "tom商家"
				}],
				"customer_message":{
					"bill商家":"bill商家订单003备注",
					"tom商家":"tom商家订单003备注"
				}
			}
			"""


	#购买商家同步商品（多个供货商）订单同步到商家后台[bill商家、tom商家]
	#待发货-004(bill商品1,1、bill商品2,1、tom商品1,1),多个供货商，部分有留言,货到付款
		When tom1访问jobs的webapp
		And tom1加入jobs的商品到购物车
			"""
			[{
				"name": "bill商品1",
				"count": 1
			}, {
				"name": "bill商品2",
				"count": 1
			}, {
				"name": "tom商品1",
				"count": 1
			}]
			"""
		When tom1从购物车发起购买操作
			"""
			{
				"action": "pay",
				"context": [{
					"name": "bill商品1"
				}, {
					"name": "bill商品2"
				}, {
					"name": "tom商品1"
				}]
			}
			"""
		And tom1在购物车订单编辑中点击提交订单
			"""
			{
				"ship_name": "AAA",
				"ship_tel": "13811223344",
				"ship_area": "北京市 北京市 海淀区",
				"ship_address": "泰兴大厦",
				"pay_type": "货到付款",
				"order_id": "004",
				"customer_message":{
					"tom商家":"tom商家订单004备注"
				}
			}
			"""
		Then tom1成功创建订单
			"""
			{
				"order_id": "004",
				"status": "待发货",
				"ship_name": "AAA",
				"ship_tel": "13811223344",
				"ship_area": "北京市 北京市 海淀区",
				"ship_address": "泰兴大厦",
				"final_price": 40.00,
				"products": [{
					"name": "bill商品1",
					"price": 10.00,
					"count": 1,
					"supplier": "bill商家"
				},{
					"name": "bill商品2",
					"price": 20.00,
					"count": 1,
					"supplier": "bill商家"
				},{
					"name": "tom商品1",
					"price": 10.00,
					"count": 1,
					"supplier": "tom商家"
				}],
				"customer_message":{
					"tom商家":"tom商家订单004备注"
				}
			}
			"""

	#购买自营平台自建商品和商家同步的商品[供货商1、bill商家、tom商家]
	#待发货-005(商品1a,1、bill商品1,1、bill商品2,1、tom商品1,1),多个供货商,部分有留言,货到付款
		When tom1访问jobs的webapp
		And tom1加入jobs的商品到购物车
			"""
			[{
				"name": "商品1a",
				"count": 1
			}, {
				"name": "bill商品1",
				"count": 1
			}, {
				"name": "bill商品2",
				"count": 1
			}, {
				"name": "tom商品1",
				"count": 1
			}]
			"""
		When tom1从购物车发起购买操作
			"""
			{
				"action": "pay",
				"context": [{
					"name": "商品1a"
				}, {
					"name": "bill商品1"
				}, {
					"name": "bill商品2"
				}, {
					"name": "tom商品1"
				}]
			}
			"""
		And tom1在购物车订单编辑中点击提交订单
			"""
			{
				"ship_name": "AAA",
				"ship_tel": "13811223344",
				"ship_area": "北京市 北京市 海淀区",
				"ship_address": "泰兴大厦",
				"pay_type": "货到付款",
				"order_id": "005",
				"customer_message":{
					"供货商1":"供货商1订单005备注",
					"bill商家":"bill商家订单005备注",
					"tom商家":"tom商家订单005备注"
				}
			}
			"""
		Then tom1成功创建订单
			"""
			{
				"order_id": "005",
				"status": "待发货",
				"ship_name": "AAA",
				"ship_tel": "13811223344",
				"ship_area": "北京市 北京市 海淀区",
				"ship_address": "泰兴大厦",
				"final_price": 50.00,
				"products": [{
					"name": "bill商品1",
					"price": 10.00,
					"count": 1,
					"supplier": "bill商家"
				},{
					"name": "bill商品2",
					"price": 20.00,
					"count": 1,
					"supplier": "bill商家"
				},{
					"name": "tom商品1",
					"price": 10.00,
					"count": 1,
					"supplier": "tom商家"
				},{
					"name": "商品1a",
					"price": 10.00,
					"count": 1,
					"supplier": "供货商1"
				}],
				"customer_message":{
					"供货商1":"供货商1订单005备注",
					"bill商家":"bill商家订单005备注",
					"tom商家":"tom商家订单005备注"
				}
			}
			"""
	#购买自营平台自建商品和商家同步的商品[供货商1、bill商家]
	#待支付-007(商品1a,1、bill商品1,1),多个供货商,均有留言,微信支付
		When tom1访问jobs的webapp
		And tom1加入jobs的商品到购物车
			"""
			[{
				"name": "商品1a",
				"count": 1
			}, {
				"name": "bill商品1",
				"count": 1
			}]
			"""
		When tom1从购物车发起购买操作
			"""
			{
				"action": "pay",
				"context": [{
					"name": "商品1a"
				}, {
					"name": "bill商品1"
				}]
			}
			"""
		And tom1在购物车订单编辑中点击提交订单
			"""
			{
				"ship_name": "AAA",
				"ship_tel": "13811223344",
				"ship_area": "北京市 北京市 海淀区",
				"ship_address": "泰兴大厦",
				"pay_type": "微信支付",
				"order_id": "007",
				"customer_message":{
					"供货商1":"供货商1订单007备注",
					"bill商家":"bill商家订单007备注"
				}
			}
			"""
		Then tom1成功创建订单
			"""
			{
				"order_id": "007",
				"status": "待支付",
				"ship_name": "AAA",
				"ship_tel": "13811223344",
				"ship_area": "北京市 北京市 海淀区",
				"ship_address": "泰兴大厦",
				"final_price": 20.00,
				"customer_message":{
					"供货商1":"供货商1订单007备注",
					"bill商家":"bill商家订单007备注"
				},
				"products": [{
					"name": "bill商品1",
					"price": 10.00,
					"count": 1,
					"supplier": "bill商家"
				},{
					"name": "商品1a",
					"price": 10.00,
					"count": 1,
					"supplier": "供货商1"
				}]
			}
			"""

@mall3 @eugene
Scenario:2 自营平台后台验证
	#购买自营平台自建商品和商家同步的商品[供货商1、bill商家、tom商家]
	#待发货-006(商品1a,1、bill商品1,1、bill商品2,1、tom商品1,1),多个供货商,均有留言,货到付款
		When tom1访问jobs的webapp
		And tom1加入jobs的商品到购物车
			"""
			[{
				"name": "商品1a",
				"count": 1
			}, {
				"name": "bill商品1",
				"count": 1
			}, {
				"name": "bill商品2",
				"count": 1
			}, {
				"name": "tom商品1",
				"count": 1
			}]
			"""
		When tom1从购物车发起购买操作
			"""
			{
				"action": "pay",
				"context": [{
					"name": "商品1a"
				}, {
					"name": "bill商品1"
				}, {
					"name": "bill商品2"
				}, {
					"name": "tom商品1"
				}]
			}
			"""
		And tom1在购物车订单编辑中点击提交订单
			"""
			{
				"ship_name": "AAA",
				"ship_tel": "13811223344",
				"ship_area": "北京市 北京市 海淀区",
				"ship_address": "泰兴大厦",
				"pay_type": "货到付款",
				"order_id": "006",
				"customer_message":{
					"供货商1":"供货商1订单006备注",
					"bill商家":"bill商家订单006备注",
					"tom商家":"tom商家订单006备注"
				}
			}
			"""
		Given jobs登录系统::weapp
		Then jobs可以看到订单列表::weapp
			"""
			[{
				"order_no":"006",
				"buyer":"tom1",
				"status": "待发货",
				"final_price":50.00,
				"save_money":"",
				"methods_of_payment": "货到付款",
				"actions": ["取消订单"],
				"customer_message":{
					"供货商1":"供货商1订单006备注",
					"bill商家":"bill商家订单006备注",
					"tom商家":"tom商家订单006备注"
				},
				"products": [{
					"name":"bill商品1",
					"price":10.0,
					"count":1,
					"supplier": "bill商家",
					"is_sync_supplier": "true",
					"status": "待发货",
					"actions": ["发货"]
				},{
					"name":"bill商品2",
					"price":20.0,
					"count":1,
					"supplier": "bill商家",
					"is_sync_supplier": "true",
					"status": "待发货",
					"actions": ["发货"]
				},{
					"name":"tom商品1",
					"price":10.0,
					"count":1,
					"supplier": "tom商家",
					"is_sync_supplier": "true",
					"status": "待发货",
					"actions": ["发货"]
				},{
					"name":"商品1a",
					"price":10.0,
					"count":1,
					"supplier": "供货商1",
					"is_sync_supplier": "false",
					"status": "待发货",
					"actions": ["发货"]
				}]
			}]
			"""
		Then jobs能获得订单'006'::weapp
			"""
			{
				"order_no":"006",
				"status": "待发货",
				"final_price":50.00,
				"methods_of_payment": "货到付款",
				"actions": ["取消订单"],
				"customer_message":{
					"供货商1":"供货商1订单006备注",
					"bill商家":"bill商家订单006备注",
					"tom商家":"tom商家订单006备注"
				},
				"products": [{
					"name":"商品1a",
					"price":10.0,
					"count":1,
					"supplier": "供货商1",
					"is_sync_supplier": "false"
				},{
					"name":"bill商品1",
					"price":10.0,
					"count":1,
					"supplier": "bill商家",
					"is_sync_supplier": "true"
				},{
					"name":"bill商品2",
					"price":20.0,
					"count":1,
					"supplier": "bill商家",
					"is_sync_supplier": "true"
				},{
					"name":"tom商品1",
					"price":10.0,
					"count":1,
					"supplier": "tom商家",
					"is_sync_supplier": "true"
				}]
			}
			"""

	#商户平台同步留言信息-bill商家
		Given bill登录系统::weapp
		Then bill可以看到订单列表::weapp
			"""
			[{
				"order_no":"006-bill商家",
				"sources": "商城",
				"buyer":"tom1",
				"status": "待发货",
				"final_price":28.00,
				"save_money":"",
				"methods_of_payment": "微信支付",
				"actions": ["发货"],
				"customer_message":"bill商家订单006备注",
				"products":
					[{
						"name":"bill商品1",
						"price":"",
						"count":1
					},{
						"name":"bill商品2",
						"price":"",
						"count":1
					}]
			}]
			"""
		Then bill能获得订单'006-bill商家'::weapp
			"""
			{
				"order_no":"006-bill商家",
				"sources": "商城",
				"status": "待发货",
				"final_price":28.00,
				"methods_of_payment": "微信支付",
				"actions": ["发货"],
				"customer_message":"bill商家订单006备注",
				"products":
					[{
						"name":"bill商品1",
						"price":9.0,
						"count":1
					},{
						"name":"bill商品2",
						"price":19.0,
						"count":1
					}]
			}
			"""

	#商户平台同步留言信息-tom商家
		Given tom登录系统::weapp
		Then tom可以看到订单列表::weapp
			"""
			[{
				"order_no":"006-tom商家",
				"sources": "商城",
				"buyer":"tom1",
				"status": "待发货",
				"final_price":9.00,
				"save_money":"",
				"methods_of_payment": "微信支付",
				"actions": ["发货"],
				"customer_message":"tom商家订单006备注",
				"products":
					[{
						"name":"tom商品1",
						"price":"",
						"count":1
					}]
			}]
			"""
		Then tom能获得订单'006-tom商家'::weapp
			"""
			{
				"order_no":"006-tom商家",
				"sources": "商城",
				"status": "待发货",
				"final_price":9.00,
				"methods_of_payment": "微信支付",
				"actions": ["发货"],
				"customer_message":"tom商家订单006备注",
				"products":
					[{
						"name":"tom商品1",
						"price":9.0,
						"count":1
					}]
			}
			"""

#补充.田丰敏 2016.05.30
Scenario:3 自营平台和商户平台导出订单
	#购买自营平台自建商品和商家同步的商品[供货商1、bill商家、tom商家]
	#待发货-008(商品1a,1、bill商品1,1、bill商品2,1、tom商品1,1),多个供货商,供货商1、bill商家有留言,货到付款
		When tom1访问jobs的webapp
		And tom1加入jobs的商品到购物车
			"""
			[{
				"name": "商品1a",
				"count": 1
			}, {
				"name": "bill商品1",
				"count": 1
			}, {
				"name": "bill商品2",
				"count": 1
			}, {
				"name": "tom商品1",
				"count": 1
			}]
			"""
		When tom1从购物车发起购买操作
			"""
			{
				"action": "pay",
				"context": [{
					"name": "商品1a"
				}, {
					"name": "bill商品1"
				}, {
					"name": "bill商品2"
				}, {
					"name": "tom商品1"
				}]
			}
			"""
		And tom1在购物车订单编辑中点击提交订单
			"""
			{
				"ship_name": "AAA",
				"ship_tel": "13811223344",
				"ship_area": "北京市 北京市 海淀区",
				"ship_address": "泰兴大厦",
				"pay_type": "货到付款",
				"order_id": "008",
				"customer_message":{
					"供货商1":"供货商1订单008备注",
					"bill商家":"bill商家订单008备注"
				}
			}
			"""

		When tom1访问jobs的webapp
		And tom1加入jobs的商品到购物车
			"""
			[{
				"name": "bill商品1",
				"count": 1
			}, {
				"name": "bill商品2",
				"count": 1
			}]
			"""
		When tom1从购物车发起购买操作
			"""
			{
				"action": "pay",
				"context": [{
					"name": "bill商品1"
				}, {
					"name": "bill商品2"
				}]
			}
			"""
		And tom1在购物车订单编辑中点击提交订单
			"""
			{
				"ship_name": "AAA",
				"ship_tel": "13811223344",
				"ship_area": "北京市 北京市 海淀区",
				"ship_address": "泰兴大厦",
				"pay_type": "货到付款",
				"order_id": "009",
				"customer_message":{
					"bill商家": "bill商家订单009备注"
				}
			}
			"""
		Given jobs登录系统::weapp
		Then jobs导出订单获取订单信息::weapp
			|    order_no     |  order_time |   pay_time    | product_name |  model | product_unit_price | count | sales_money | weight | methods_of_payment | money_total | money | money_wcard | postage | integral | coupon_money | coupon_name |  status   | member | ship_name |  ship_tele  | ship_province |        ship_address           | shipper | leader_remark | sources | supplier_type | logistics |   number  | delivery_time | remark |  customer_message  | customer_source | customer_recommender | is_qr_code | is_older_mermber | purchase_price | purchase_costs |
			|   009-bill商家  |     今天    |      今天     |   bill商品1  |        |        10.00       |   1   |    10.00    |   2    |      货到付款      |    30.00    | 30.00 |     0.00    |  0.00   |   0.00   |              |             |  待发货   |  tom1  |    AAA    | 13811223344 |    北京市     |    北京市 北京市 海淀区       |         |               | bill商家|   同步供货商  |           |           |               |        |bill商家订单009备注 |    直接关注     |                      |            |                  |      9.00      |      9.00      |
			|   009-bill商家  |     今天    |      今天     |   bill商品2  |        |        20.00       |   1   |    20.00    |   2    |      货到付款      |             |       |             |  0.00   |          |              |             |  待发货   |  tom1  |    AAA    | 13811223344 |    北京市     |    北京市 北京市 海淀区       |         |               | bill商家|   同步供货商  |           |           |               |        |bill商家订单009备注 |    直接关注     |                      |            |                  |      19.00     |      19.00     |
			|   008           |     今天    |      今天     |    商品1a    |        |        10.00       |   1   |    10.00    |   2    |      货到付款      |    50.00    | 50.00 |     0.00    |  0.00   |   0.00   |              |             |  待发货   |  tom1  |    AAA    | 13811223344 |    北京市     |    北京市 北京市 海淀区       |         |               | 供货商1 |   自建供货商  |           |           |               |        |供货商1订单008备注  |    直接关注     |                      |            |                  |      9.00      |      9.00      |
			|   008-bill商家  |     今天    |      今天     |   bill商品1  |        |        10.00       |   1   |    10.00    |   2    |      货到付款      |             |       |             |  0.00   |          |              |             |  待发货   |  tom1  |    AAA    | 13811223344 |    北京市     |    北京市 北京市 海淀区       |         |               | bill商家|   同步供货商  |           |           |               |        |bill商家订单008备注 |    直接关注     |                      |            |                  |      9.00      |      9.00      |
			|   008-bill商家  |     今天    |      今天     |   bill商品2  |        |        20.00       |   1   |    20.00    |   2    |      货到付款      |             |       |             |  0.00   |          |              |             |  待发货   |  tom1  |    AAA    | 13811223344 |    北京市     |    北京市 北京市 海淀区       |         |               | bill商家|   自建供货商  |           |           |               |        |bill商家订单008备注 |    直接关注     |                      |            |                  |      19.00     |      19.00     |
			|   008-tom商家   |     今天    |      今天     |   tom商品1   |        |        10.00       |   1   |    10.00    |   2    |      货到付款      |             |       |             |  0.00   |          |              |             |  待发货   |  tom1  |    AAA    | 13811223344 |    北京市     |    北京市 北京市 海淀区       |         |               | tom商家 |   同步供货商  |           |           |               |        |                    |    直接关注     |                      |            |                  |      10.00     |      10.00     |
		
		Then jobs导出订单获取订单统计信息::weapp
			"""
			[{
				"订单量":2,
				"已完成":0,
				"商品金额":80.00,
				"支付总额":80.00,
				"现金支付金额":80.00,
				"微众卡支付金额":0.00,
				"赠品总数":0,
				"积分抵扣总金额":0.00,
				"优惠劵价值总额":0.00
			}]
			"""

		Given bill登录系统::weapp
		Then bill导出订单获取订单信息::weapp
			|   order_no   |  order_time | pay_time | product_name |  model | product_unit_price | count | sales_money | weight | methods_of_payment | money_total | money | money_wcard | postage | integral | coupon_money | coupon_name |  status   | member | ship_name  |  ship_tel   | ship_province |      ship_address    | shipper | leader_remark | sources | logistics |   number  | delivery_time | remark   |  customer_message   | customer_source | customer_recommender | is_qr_code | is_older_mermber |
			| 009-bill商家 |     今天    |   今天   |    bill商品1 |        |        9.00        |   1   |    9.00     |    2   |     微信支付       |     28.0    |  28.0 |    0.00     |  0.00   |   0.00   |     0.00     |             |  待发货   |  tom1  |    AAA     | 13811223344 |    北京市     | 北京市,北京市,海淀区 |         |               |  商城   |           |           |      今天     |          | bill商家订单009备注 |     直接关注    |                      |            |                  |
			| 009-bill商家 |     今天    |   今天   |    bill商品2 |        |        19.00       |   1   |    19.00    |    2   |     微信支付       |             |       |             |         |          |              |             |  待发货   |  tom1  |    AAA     | 13811223344 |    北京市     | 北京市,北京市,海淀区 |         |               |  商城   |           |           |      今天     |          | bill商家订单009备注 |     直接关注    |                      |            |                  |
			| 008-bill商家 |     今天    |   今天   |    bill商品1 |        |        9.00        |   1   |    9.00     |    2   |     微信支付       |     28.0    |  28.0 |    0.00     |  0.00   |   0.00   |     0.00     |             |  待发货   |  tom1  |    AAA     | 13811223344 |    北京市     | 北京市,北京市,海淀区 |         |               |  商城   |           |           |      今天     |          | bill商家订单008备注 |     直接关注    |                      |            |                  |
			| 008-bill商家 |     今天    |   今天   |    bill商品2 |        |        19.00       |   1   |    19.00    |    2   |     微信支付       |             |       |             |         |          |              |             |  待发货   |  tom1  |    AAA     | 13811223344 |    北京市     | 北京市,北京市,海淀区 |         |               |  商城   |           |           |      今天     |          | bill商家订单008备注 |     直接关注    |                      |            |                  |

		Then bill导出订单获取订单统计信息::weapp
			"""
			[{
				"订单量":2,
				"已完成":0,
				"商品金额":56.00,
				"支付总额":56.00,
				"现金支付金额":56.00,
				"微众卡支付金额":0.00,
				"赠品总数":0,
				"积分抵扣总金额":0.00,
				"优惠劵价值总额":0.00
			}]
			"""