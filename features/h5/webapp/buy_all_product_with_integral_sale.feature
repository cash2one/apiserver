# watcher: benchi@weizoom.com, wangli@weizoom.com
#author: benchi
#editor: 师帅 2015.10.19
#editor: 王丽 2015.11.25
#editor: 玉成 2015.12.14
Feature: 在webapp中购买参与积分应用活动的商品
	jobs 设置 use_ceiling 后 用户能在webapp中能够对所有商品使用积分购买

Background:
	Given 重置'weapp'的bdd环境
	Given jobs登录系统::weapp
	And jobs已添加商品规格::weapp
		"""
		[{
			"name": "尺寸",
			"type": "文字",
			"values": [{
				"name": "M"
			}, {
				"name": "S"
			}]
		}]
		"""
	And jobs已添加商品::weapp
		"""
		[{
			"name": "商品1",
			"price": 100.00,
			"model": {
				"models": {
					"standard": {
						"price": 100.00,
						"stock_type": "有限",
						"stocks": 2
					}
				}
			}
		}, {
			"name": "商品2",
			"price": 200.00
		}, {
			"name": "商品3",
			"price": 50.00
		}, {
			"name": "商品4",
			"model": {
				"models": {
					"standard": {
						"price": 40.00,
						"stock_type": "有限",
						"stocks": 20
					}
				}
			}
		}, {
			"name": "商品5",
			"is_enable_model": "启用规格",
			"model": {
				"models":{
					"M": {
						"price": 40.00,
						"stock_type": "无限"
					},
					"S": {
						"price": 40.00,
						"stock_type": "无限"
					}
				}
			}
		}]
		"""
	Given jobs设定会员积分策略::weapp
		"""
		{
			"integral_each_yuan": 2,
			"use_ceiling": 50
		}
		"""
	#支付方式
	Given jobs已添加支付方式::weapp
		"""
		[{
			"type": "微信支付",
			"is_active": "启用"
		}, {
			"type": "货到付款",
			"is_active": "启用"
		}]
		"""

	Given bill关注jobs的公众号
	And tom关注jobs的公众号

@mall3 @mall2 @mall.promotion @mall.webapp.promotion @bert @wip.bapwis1
Scenario:1 购买单种一个商品，积分金额小于最大折扣金额
	When bill访问jobs的webapp
	When bill获得jobs的50会员积分
	Then bill在jobs的webapp中拥有50会员积分
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"integral_money":25.00,
			"integral":50.00,
			"products": [{
				"name": "商品1",
				"count": 1
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 75.00,
			"product_price": 100.00,
			"integral_money":25.00,
			"integral":50.00,
			"products": [{
				"name": "商品1",
				"count": 1
			}]
		}
		"""
	Then bill在jobs的webapp中拥有0会员积分

@mall3 @mall2 @mall.promotion @mall.webapp.promotion @bert
Scenario:2 购买单种多个商品，积分金额等于最大折扣金额
	When bill访问jobs的webapp
	When bill获得jobs的400会员积分
	Then bill在jobs的webapp中拥有400会员积分
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"integral_money":200.00,
			"integral":400,
			"products": [{
				"name": "商品2",
				"count": 2
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 200.00,
			"product_price": 400.00,
			"integral_money":200.00,
			"integral":400,
			"products": [{
				"name": "商品2",
				"count": 2
			}]
		}
		"""
	Then bill在jobs的webapp中拥有0会员积分

@mall3 @mall2 @mall.promotion @mall.webapp.promotion @bert
Scenario:3 购买多个商品，已有总积分金额大于最大折扣金额
	When bill访问jobs的webapp
	When bill获得jobs的160会员积分
	Then bill在jobs的webapp中拥有160会员积分
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"integral_money":75.00,
			"integral":150,
			"products": [{
				"name": "商品1",
				"count": 1
			}, {
				"name": "商品3",
				"count": 1
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 75.00,
			"product_price": 150.00,
			"integral_money":75.00,
			"integral":150,
			"products": [{
				"name": "商品1",
				"count": 1
			}, {
				"name": "商品3",
				"count": 1
			}]
		}
		"""
	Then bill在jobs的webapp中拥有10会员积分

@mall3 @mall2 @mall.promotion @mall.webapp.promotion @bert @acb
Scenario:4 购买单个多规格商品+一个普通商品
	When bill访问jobs的webapp
	When bill获得jobs的150会员积分
	Then bill在jobs的webapp中拥有150会员积分
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"integral_money": 65.00,
			"integral": 130,
			"products": [{
				"name": "商品5",
				"count": 1,
				"model": "S"
			}, {
				"name": "商品5",
				"count": 1,
				"model": "M"
			}, {
				"name": "商品3",
				"count": 1
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 65.00,
			"product_price": 130.00,
			"integral_money": 65.00,
			"integral": 130,
			"products": [{
				"name": "商品5",
				"count": 1,
				"model": "S"
			}, {
				"name": "商品5",
				"count": 1,
				"model": "M"
			}, {
				"name": "商品3",
				"count": 1
			}]
		}
		"""
	Then bill在jobs的webapp中拥有20会员积分

@mall3 @mall2 @mall.promotion @mall.webapp.promotion @bert
Scenario:5 购买单个限时抢购商品，同时使用积分购买
	Given jobs登录系统::weapp
	When jobs创建限时抢购活动::weapp
		"""
		{
			"name": "商品1限时抢购",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品1",
			"promotion_price": 10.00
		}
		"""
	When bill访问jobs的webapp
	When bill获得jobs的50会员积分
	Then bill在jobs的webapp中拥有50会员积分
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"integral_money":5.00,
			"integral":10,
			"products": [{
				"name": "商品1",
				"count": 1
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 5.00,
			"product_price": 10.00,
			"promotion_saved_money":90.00,
			"integral_money":5.00,
			"integral":10,
			"products": [{
				"name": "商品1",
				"count": 1,
				"total_price": 100.00
			}]
		}
		"""
	Then bill在jobs的webapp中拥有40会员积分

@mall3 @mall2 @mall.promotion @mall.webapp.promotion @bert
Scenario:6 购买单个限时抢购商品， 买赠商品，同时使用积分购买
	Given jobs登录系统::weapp
	When jobs创建限时抢购活动::weapp
		"""
		{
			"name": "商品1限时抢购",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品1",
			"promotion_price": 10.00
		}
		"""

	When jobs创建买赠活动::weapp
		"""
		{
			"name": "商品2买一赠一",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品2",
			"premium_products": [{
				"name": "商品4",
				"count": 5
			}],
			"count": 1,
			"is_enable_cycle_mode": true
		}
		"""
	When bill访问jobs的webapp
	When bill获得jobs的500会员积分
	Then bill在jobs的webapp中拥有500会员积分
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"integral_money":205.00,
			"integral":410,
			"products": [{
				"name": "商品1",
				"count": 1
			},{
				"name": "商品2",
				"count": 2
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 205.00,
			"product_price": 410.00,
			"promotion_saved_money":90.00,
			"integral_money":205.00,
			"integral":410,
			"products": [{
				"name": "商品1",
				"count": 1,
				"price": 10.00,
				"total_price": 100.00
			},{
				"name": "商品2",
				"count": 2
			},{
				"name": "商品4",
				"count": 10,
				"price": 0.00,
				"promotion": {
					"type": "premium_sale:premium_product"
				}
			}]
		}
		"""
	Then bill在jobs的webapp中拥有90会员积分

#补充：张三香 "雪静"
@mall3 @mall2 @integral @meberGrade @bert
Scenario: 7 不同等级的会员购买有会员价同时有全体积分抵扣50%的商品
	#会员价和积分抵扣可以同时使用，会员价后再算积分抵扣的比例
	Given jobs登录系统::weapp
	And jobs已添加商品::weapp
		"""
			[{
				"name": "商品10",
				"price": 100.00,
				"is_member_product": "on"
			},{
				"name": "商品11",
				"price": 100.00,
				"is_member_product": "on"
			}]
		"""

	And tom4关注jobs的公众号
	And tom3关注jobs的公众号
	And tom2关注jobs的公众号
	And tom1关注jobs的公众号
	Given jobs登录系统::weapp
	When jobs添加会员等级::weapp
		"""
		[{
			"name": "铜牌会员",
			"upgrade": "手动升级",
			"discount": "9"
		}, {
			"name": "银牌会员",
			"upgrade": "手动升级",
			"discount": "8"
		}, {
			"name": "金牌会员",
			"upgrade": "手动升级",
			"discount": "7"
		}]
		"""
	When jobs更新'tom4'的会员等级::weapp
		"""
		{
			"name": "tom4",
			"member_rank": "金牌会员"
		}
		"""
	And jobs更新'tom3'的会员等级::weapp
		"""
		{
			"name": "tom3",
			"member_rank": "银牌会员"
		}
		"""
	And jobs更新'tom2'的会员等级::weapp
		"""
		{
			"name": "tom2",
			"member_rank": "铜牌会员"
		}
		"""
	When jobs访问会员列表::weapp
	Then jobs获得会员列表默认查询条件::weapp
	Then jobs可以获得会员列表::weapp
		"""
		[{
			"name": "tom1",
			"member_rank": "普通会员"
		}, {
			"name": "tom2",
			"member_rank": "铜牌会员"
		}, {
			"name": "tom3",
			"member_rank": "银牌会员"
		}, {
			"name": "tom4",
			"member_rank": "金牌会员"
		},{
			"name": "tom",
			"member_rank": "普通会员"
		}, {
			"name": "bill",
			"member_rank": "普通会员"
		}]
		"""
	#701会员tom1购买商品10，使用积分抵扣最高：50元，订单金额：50元
	When tom1访问jobs的webapp
	When tom1获得jobs的100会员积分
	Then tom1在jobs的webapp中拥有100会员积分
	When tom1购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"integral_money":50.00,
			"integral":100,
			"products": [{
				"name": "商品10",
				"count": 1
			}]
		}
		"""
	Then tom1成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 50.00,
			"product_price": 100.00,
			"integral_money":50.00,
			"integral":100,
			"products": [{
				"name": "商品10",
				"count": 1
			}]
		}
		"""
	Then tom1在jobs的webapp中拥有0会员积分

	#702会员tom2购买商品10，使用积分抵扣最高：45元，订单金额：45元
	When tom2访问jobs的webapp
	When tom2获得jobs的200会员积分
	Then tom2在jobs的webapp中拥有200会员积分
	When tom2购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"integral_money":45.00,
			"integral":90,
			"products": [{
				"name": "商品10",
				"count": 1
			}]
		}
		"""
	Then tom2成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 45.00,
			"product_price": 90.00,
			"integral_money":45.00,
			"integral":90,
			"products": [{
				"name": "商品10",
				"count": 1
			}]
		}
		"""
	Then tom2在jobs的webapp中拥有110会员积分

	#703会员tom4购买商品10+商品11，使用积分抵扣最高：70元，订单金额：70元
	When tom4访问jobs的webapp
	When tom4获得jobs的400会员积分
	Then tom4在jobs的webapp中拥有400会员积分
	When tom4购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"integral_money":70.00,
			"integral":140,
			"products": [{
				"name": "商品10",
				"count": 1
			},{
				"name": "商品11",
				"count": 1
			}]
		}
		"""
	Then tom4成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 70.00,
			"product_price": 140.00,
			"integral_money":70.00,
			"integral":140,
			"products": [{
				"name": "商品10",
				"count": 1
			},{
				"name": "商品11",
				"count": 1
			}]
		}
		"""
	Then tom4在jobs的webapp中拥有260会员积分


	#704会员tom3购买商品11，积分抵扣金额小于商品会员价金额，使用积分抵扣最高：30元，订单金额：50元
	When tom3访问jobs的webapp
	When tom3获得jobs的60会员积分
	Then tom3在jobs的webapp中拥有60会员积分
	When tom3购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"integral_money":30.00,
			"integral":60,
			"products": [{
				"name": "商品11",
				"count": 1
			}]
		}
		"""
	Then tom3成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 50.00,
			"product_price": 80.00,
			"integral_money":30.00,
			"integral":60,
			"products": [{
				"name": "商品11",
				"count": 1
			}]
		}
		"""
	Then tom3在jobs的webapp中拥有0会员积分

#补充.雪静
@mall3 @mall2 @integral @bert 
Scenario: 8 使用积分能抵扣小数
	使用积分抵扣带有小数的金额
	1.抵扣金额小于1元的小数
	2.抵扣金额大于1元的小数

	Given jobs登录系统::weapp
	And jobs已添加商品::weapp
		"""
		[{
			"name": "商品10",
			"price": 1.00
		},{
			"name": "商品11",
			"price": 2.50
		}]
		"""
	When bill访问jobs的webapp
	When bill获得jobs的50会员积分
	Then bill在jobs的webapp中拥有50会员积分
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"integral_money": 0.50,
			"integral": 1,
			"products": [{
				"name": "商品10",
				"count": 1
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 0.50,
			"product_price": 1.00,
			"integral_money": 0.50,
			"integral": 1,
			"products": [{
				"name": "商品10",
				"count": 1
			}]
		}
		"""
	Then bill在jobs的webapp中拥有49会员积分
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"integral_money": 1.25,
			"integral": 3,
			"products": [{
				"name": "商品11",
				"count": 1
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 1.25,
			"product_price": 2.50,
			"integral_money": 1.25,
			"integral": 3,
			"products": [{
				"name": "商品11",
				"count": 1
			}]
		}
		"""
	Then bill在jobs的webapp中拥有46会员积分
