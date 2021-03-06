# watcher: benchi@weizoom.com, wangli@weizoom.com
#editor: benchi
#editor: 师帅 2015.10.20
#editor: 王丽 2015.12.25

Feature:使用微众卡购买商品
	用户能通过webapp使用微众卡购买jobs的商品
	feathure里要加一个  "weizoom_card_money":50.00,的字段

Background:
	Given 重置'weapp'的bdd环境
	Given 重置'weizoom_card'的bdd环境
	Given jobs登录系统::weapp
	And jobs已有微众卡支付权限::weapp
	And jobs已添加支付方式::weapp
		"""
		[{
			"type":"货到付款"
		},{
			"type":"微信支付"
		},{
			"type":"支付宝"
		},{
			"type":"微众卡支付"
		}]
		"""
	And jobs已添加商品::weapp
		"""
		[{
			"name": "商品1",
			"price": 50.00
		},{
			"name": "商品2",
			"price": 20.00
		}]
		"""

	#创建微众卡
	Given test登录管理系统::weizoom_card
	When test新建通用卡::weizoom_card
		"""
		[{
			"name":"100元微众卡",
			"prefix_value":"100",
			"type":"virtual",
			"money":"100.00",
			"num":"1",
			"comments":"微众卡"
		},{
			"name":"50元微众卡",
			"prefix_value":"050",
			"type":"virtual",
			"money":"50.00",
			"num":"2",
			"comments":"微众卡"
		},{
			"name":"30元微众卡",
			"prefix_value":"030",
			"type":"virtual",
			"money":"30.00",
			"num":"3",
			"comments":"微众卡"
		},{
			"name":"0元微众卡",
			"prefix_value":"000",
			"type":"virtual",
			"money":"10.00",
			"num":"1",
			"comments":"微众卡"
		},{
			"name":"1元微众卡",
			"prefix_value":"001",
			"type":"virtual",
			"money":"1.00",
			"num":"11",
			"comments":"微众卡"
		}]
		"""

	#微众卡审批出库
	When test下订单::weizoom_card
		"""
		[{
			"card_info":[{
				"name":"100元微众卡",
				"order_num":"1",
				"start_date":"2016-04-07 00:00",
				"end_date":"2019-10-07 00:00"
			},{
				"name":"50元微众卡",
				"order_num":"2",
				"start_date":"2016-04-07 00:00",
				"end_date":"2019-10-07 00:00"
			},{
				"name":"30元微众卡",
				"order_num":"3",
				"start_date":"2016-04-07 00:00",
				"end_date":"2019-10-07 00:00"
			},{
				"name":"0元微众卡",
				"order_num":"1",
				"start_date":"2016-04-07 00:00",
				"end_date":"2019-10-07 00:00"
			}],
			"order_info":{
				"order_id":"0001"
				}
		}]
		"""

	When test下订单::weizoom_card
		"""
		[{
			"card_info":[{
				"name":"1元微众卡",
				"order_num":"11",
				"start_date":"2016-04-07 00:00",
				"end_date":"2019-10-07 00:00"
			}],
			"order_info":{
				"order_id":"0002"
				}
		}]
		"""

	#激活微众
	When test激活卡号'100000001'的卡::weizoom_card
	When test激活卡号'050000001'的卡::weizoom_card
	When test激活卡号'050000002'的卡::weizoom_card
	When test激活卡号'030000001'的卡::weizoom_card
	When test激活卡号'000000001'的卡::weizoom_card

	#调整有效期（没有实现对有效期调整的功能）
	#100000001：未使用
	#050000001：已使用
	#030000001：未使用
	#030000002：未激活
	#030000003：已过期
	#000000001：已用完

	And test批量激活订单'0002'的卡::weizoom_card

	And bill关注jobs的公众号

@mall3 @mall2 @wip.bpuc1 @mall.pay_weizoom_card @victor  @weizoom_card
#购买流程.编辑订单.微众卡使用
Scenario:1 微众卡金额大于订单金额时进行支付
	bill用微众卡购买jobs的商品时,微众卡金额大于订单金额
	1.自动扣除微众卡金额
	2.创建订单成功，订单状态为“等待发货”，支付方式为“微众卡支付”
	3.微众卡金额减少,状态为“已使用”

	When bill访问jobs的webapp
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"100000001",
					"password":"1234567"
				}
		}
		"""
	Then bill能获得微众卡'100000001'的详情信息
		"""
		{
			"card_remain_value":100.00

		}
		"""

	When bill购买jobs的商品
		"""
		{
			"pay_type": "货到付款",
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}],
			"weizoom_card":[{
				"card_name":"100000001",
				"card_pass":"1234567"
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待发货",
			"final_price": 0.00,
			"product_price": 50.00,
			"weizoom_card_money":50.00,
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}]
		}
		"""
	Then bill能获得微众卡'100000001'的详情信息
		"""
		{
			"card_remain_value":50.00

		}
		"""

@mall3 @mall2 @mall.pay_weizoom_card @victor  @weizoom_card
#购买流程.编辑订单.微众卡使用
Scenario:2 微众卡金额等于订单金额时进行支付
	bill用微众卡购买jobs的商品时,微众卡金额等于订单金额
	1.自动扣除微众卡金额
	2.创建订单成功，订单状态为“等待发货”，支付方式为“微众卡支付”
	3.微众卡金额减少,状态为“已用完”

	When bill访问jobs的webapp
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"050000002",
					"password":"1234567"
				}
		}
		"""
	When bill购买jobs的商品
		"""
		{
			"pay_type": "货到付款",
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}],
			"weizoom_card":[{
				"card_name":"050000002",
				"card_pass":"1234567"
			}]
		}
		"""

	Then bill成功创建订单
		"""
		{
			"status": "待发货",
			"final_price": 0.00,
			"product_price": 50.00,
			"weizoom_card_money":50.00,
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}]
		}
		"""
	Then bill能获得微众卡'050000002'的详情信息
		"""
		{
			"card_remain_value":0.00

		}
		"""

@mall3 @mall2 @mall.pay_weizoom_card @victor  @weizoom_card
#购买流程.编辑订单.微众卡使用
Scenario:3 微众卡金额小于订单金额时进行支付
	bill用微众卡购买jobs的商品时,微众卡金额小于订单金额
	1.创建订单成功，订单状态为“等待支付”，待支付金额为订单金额减去微众卡金额
	2.微众卡金额为零,状态为“已使用”

	When bill访问jobs的webapp
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"030000001",
					"password":"1234567"
				}
		}
		"""
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}],
			"weizoom_card":[{
				"card_name":"030000001",
				"card_pass":"1234567"
			}]
		}
		"""

	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 20.00,
			"product_price": 50.00,
			"weizoom_card_money":30.00,
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}]
		}
		"""

	Then bill能获得微众卡'030000001'的详情信息
		"""
		{
			"card_remain_value":0.00

		}
		"""

@mall3 @mall2 @mall.pay_weizoom_card @victor @weizoom_card
#购买流程.编辑订单.微众卡使用
Scenario:4 用已使用过的微众卡购买商品时
	1.创建订单成功，订单状态为“待发货”
	2.扣除微众卡金额,状态为“已用完”

	When bill访问jobs的webapp
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"050000001",
					"password":"1234567"
				}
		}
		"""
	When bill购买jobs的商品
		"""
		{
			"order_id":"0001",
			"pay_type": "微信支付",
			"products":[{
				"name":"商品2",
				"price":20.00,
				"count":1
			}],
			"weizoom_card":[{
				"card_name":"050000001",
				"card_pass":"1234567"
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"order_id": "0001",
			"status": "待发货",
			"final_price": 0.00,
			"product_price": 20.00,
			"weizoom_card_money":20.00,
			"products":[{
				"name":"商品2",
				"price":20.00,
				"count":1
			}]
		}
		"""
	Then bill能获得微众卡'050000001'的详情信息
		"""
		{
			"card_remain_value":30.00

		}
		"""

	#使用已使用的微众购买商品
	When bill访问jobs的webapp
	When bill购买jobs的商品
		"""
		{
			"order_id":"0002",
			"pay_type": "微信支付",
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}],
			"weizoom_card":[{
				"card_name":"050000001",
				"card_pass":"1234567"
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"order_id": "0002",
			"status": "待支付",
			"final_price": 20.00,
			"product_price": 50.00,
			"weizoom_card_money":30.00,
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}]
		}
		"""
	Then bill能获得微众卡'050000001'的详情信息
		"""
		{
			"card_remain_value":0.00

		}
		"""

@mall3 @mall2 @mall.pay_weizoom_card @victor @weizoom_card
#购买流程.编辑订单.微众卡使用
Scenario:6 用10张微众卡共同支付
	1.创建订单成功，订单状态为“待支付”
	2.扣除微众卡金额,状态为“已用完”

	When bill访问jobs的webapp
	#绑定微众卡
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000001",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000002",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000003",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000004",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000005",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000006",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000007",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000008",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000009",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000010",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000011",
					"password":"1234567"
				}
		}
		"""

	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}],
			"weizoom_card":[{
				"card_name":"001000001",
				"card_pass":"1234567"
			},{
				"card_name":"001000002",
				"card_pass":"1234567"
			},{
				"card_name":"001000003",
				"card_pass":"1234567"
			},{
				"card_name":"001000004",
				"card_pass":"1234567"
			},{
				"card_name":"001000005",
				"card_pass":"1234567"
			},{
				"card_name":"001000006",
				"card_pass":"1234567"
			},{
				"card_name":"001000007",
				"card_pass":"1234567"
			},{
				"card_name":"001000008",
				"card_pass":"1234567"
			},{
				"card_name":"001000009",
				"card_pass":"1234567"
			},{
				"card_name":"001000010",
				"card_pass":"1234567"
			}]
		}
		"""

	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 40.00,
			"product_price": 50.00,
			"weizoom_card_money":10.00,
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}]
		}
		"""

	#查询微众卡余额
		#001000001
		Then bill能获得微众卡'001000001'的详情信息
			"""
			{
				"card_remain_value":0.00

			}
			"""
		#001000002
		Then bill能获得微众卡'001000002'的详情信息
			"""
			{
				"card_remain_value":0.00

			}
			"""
		#001000003
		Then bill能获得微众卡'001000003'的详情信息
			"""
			{
				"card_remain_value":0.00

			}
			"""
		#001000004
		Then bill能获得微众卡'001000004'的详情信息
			"""
			{
				"card_remain_value":0.00

			}
			"""
		#001000005
		Then bill能获得微众卡'001000005'的详情信息
			"""
			{
				"card_remain_value":0.00

			}
			"""
		#001000006
		Then bill能获得微众卡'001000006'的详情信息
			"""
			{
				"card_remain_value":0.00

			}
			"""
		#001000007
		Then bill能获得微众卡'001000007'的详情信息
			"""
			{
				"card_remain_value":0.00

			}
			"""
		#001000008
		Then bill能获得微众卡'001000008'的详情信息
			"""
			{
				"card_remain_value":0.00

			}
			"""
		#001000009
		Then bill能获得微众卡'001000009'的详情信息
			"""
			{
				"card_remain_value":0.00

			}
			"""
		#001000010
		Then bill能获得微众卡'001000010'的详情信息
			"""
			{
				"card_remain_value":0.00

			}
			"""
		#001000011
		Then bill能获得微众卡'001000011'的详情信息
			"""
			{
				"card_remain_value":1.00

			}
			"""

@mall3 @mall2 @mall.pay_weizoom_card @victor
#购买流程.编辑订单.微众卡使用
Scenario:7 用11张微众卡共同支付
	1.创建订单失败错误提示：只能使用10张微众卡
	2.微众卡金额,状态不变

	When bill访问jobs的webapp
	#绑定微众卡
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000001",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000002",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000003",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000004",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000005",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000006",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000007",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000008",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000009",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000010",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000011",
					"password":"1234567"
				}
		}
		"""
	When bill购买jobs的商品
		"""
		{
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}],
			"weizoom_card":[{
				"card_name":"001000001",
				"card_pass":"1234567"
			},{
				"card_name":"001000002",
				"card_pass":"1234567"
			},{
				"card_name":"001000003",
				"card_pass":"1234567"
			},{
				"card_name":"001000004",
				"card_pass":"1234567"
			},{
				"card_name":"001000005",
				"card_pass":"1234567"
			},{
				"card_name":"001000006",
				"card_pass":"1234567"
			},{
				"card_name":"001000007",
				"card_pass":"1234567"
			},{
				"card_name":"001000008",
				"card_pass":"1234567"
			},{
				"card_name":"001000009",
				"card_pass":"1234567"
			},{
				"card_name":"001000010",
				"card_pass":"1234567"
			},{
				"card_name":"001000011",
				"card_pass":"1234567"
			}]
		}
		"""

	Then bill获得创建订单失败的信息'微众卡只能使用十张'

	#查询微众卡余额
		#001000001
		Then bill能获得微众卡'001000001'的详情信息
			"""
			{
				"card_remain_value":1.00

			}
			"""
		#001000002
		Then bill能获得微众卡'001000002'的详情信息
			"""
			{
				"card_remain_value":1.00

			}
			"""
		#001000003
		Then bill能获得微众卡'001000003'的详情信息
			"""
			{
				"card_remain_value":1.00

			}
			"""
		#001000004
		Then bill能获得微众卡'001000004'的详情信息
			"""
			{
				"card_remain_value":1.00

			}
			"""
		#001000005
		Then bill能获得微众卡'001000005'的详情信息
			"""
			{
				"card_remain_value":1.00

			}
			"""
		#001000006
		Then bill能获得微众卡'001000006'的详情信息
			"""
			{
				"card_remain_value":1.00

			}
			"""
		#001000007
		Then bill能获得微众卡'001000007'的详情信息
			"""
			{
				"card_remain_value":1.00

			}
			"""
		#001000008
		Then bill能获得微众卡'001000008'的详情信息
			"""
			{
				"card_remain_value":1.00

			}
			"""
		#001000009
		Then bill能获得微众卡'001000009'的详情信息
			"""
			{
				"card_remain_value":1.00

			}
			"""
		#001000010
		Then bill能获得微众卡'001000010'的详情信息
			"""
			{
				"card_remain_value":1.00

			}
			"""
		#001000011
		Then bill能获得微众卡'001000011'的详情信息
			"""
			{
				"card_remain_value":1.00

			}
			"""

@mall3 @mall2 @mall @mall.pay_weizoom_card @victor @weizoom_card
#购买流程.编辑订单.微众卡使用
Scenario:9 用两张微众卡购买，第一张卡的金额大于商品金额
	1.使用两张微众卡进行购买，微众卡金额大于商品金额
	2.第一张微众卡还有余额
	3.第二张微众卡还有余额

	When bill访问jobs的webapp
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"100000001",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"030000001",
					"password":"1234567"
				}
		}
		"""
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}],
			"weizoom_card":[{
				"card_name":"100000001",
				"card_pass":"1234567"
			},{
				"card_name":"030000001",
				"card_pass":"1234567"
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待发货",
			"final_price": 0.00,
			"product_price": 50.00,
			"weizoom_card_money":50.00,
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}]
		}
		"""

	Then bill能获得微众卡'100000001'的详情信息
		"""
		{
			"card_remain_value":50.00

		}
		"""
	Then bill能获得微众卡'030000001'的详情信息
		"""
		{
			"card_remain_value":30.00

		}
		"""

#根据bug补充7240#新新
@mall3 @mall.pay_weizoom_card @victor @wip.bpuc13 @ztq @weizoom_card
#购买流程.编辑订单.微众卡使用
Scenario:10 用两张微众卡购买，第二张卡的金额大于商品金额
	1.使用两张微众卡进行购买，微众卡金额大于商品金额
	2.第一张微众卡余额为0
	3.第二张微众卡还有余额

	When bill访问jobs的webapp
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"030000001",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"100000001",
					"password":"1234567"
				}
		}
		"""
	When bill购买jobs的商品
		"""
		{
			"order_id":"001",
			"pay_type": "微信支付",
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}],
			"weizoom_card":[{
				"card_name":"030000001",
				"card_pass":"1234567"
			},{
				"card_name":"100000001",
				"card_pass":"1234567"
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"order_id":"001",
			"status": "待发货",
			"final_price": 0.00,
			"product_price": 50.00,
			"weizoom_card_money":50.00,
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}]
		}
		"""

	Then bill能获得微众卡'030000001'的详情信息
		"""
		{
			"card_remain_value":0.00

		}
		"""
	Then bill能获得微众卡'100000001'的详情信息
		"""
		{
			"card_remain_value":80.00

		}
		"""

	Given jobs登录系统::weapp
	When jobs'取消'订单'001'::weapp

	When bill访问jobs的webapp
	Then bill能获得微众卡'030000001'的详情信息
		"""
		{
			"card_remain_value":30.00

		}
		"""
	Then bill能获得微众卡'100000001'的详情信息
		"""
		{
			"card_remain_value":100.00

		}
		"""

#根据bug补充7240#新新
@mall3 @mall.pay_weizoom_card @victor @wip.bpuc14 @ztq @weizoom_card
#购买流程.编辑订单.微众卡使用
Scenario:11 用两张微众卡购买，2张卡小于商品金额,购买待支付状态
	1.使用两张微众卡进行购买，bill取消订单

	When bill访问jobs的webapp
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"001000001",
					"password":"1234567"
				}
		}
		"""
	When bill绑定微众卡
		"""
		{
			"binding_date":"2016-06-16",
			"binding_shop":"jobs",
			"weizoom_card_info":
				{
					"id":"030000001",
					"password":"1234567"
				}
		}
		"""
	When bill购买jobs的商品
		"""
		{
			"order_id":"001",
			"pay_type": "微信支付",
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}],
			"weizoom_card":[{
				"card_name":"001000001",
				"card_pass":"1234567"
			}, {
				"card_name":"030000001",
				"card_pass":"1234567"
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"order_id":"001",
			"status": "待支付",
			"final_price": 19.00,
			"product_price": 50.00,
			"weizoom_card_money":31.00,
			"products":[{
				"name":"商品1",
				"price":50.00,
				"count":1
			}]
		}
		"""

	Then bill能获得微众卡'030000001'的详情信息
		"""
		{
			"card_remain_value":0.00

		}
		"""
	Then bill能获得微众卡'001000001'的详情信息
		"""
		{
			"card_remain_value":0.00

		}
		"""

	When bill取消订单'001'

	Then bill能获得微众卡'030000001'的详情信息
		"""
		{
			"card_remain_value":30.00

		}
		"""
	Then bill能获得微众卡'001000001'的详情信息
		"""
		{
			"card_remain_value":1.00

		}
		"""


