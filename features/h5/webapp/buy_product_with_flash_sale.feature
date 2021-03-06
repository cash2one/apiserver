# watcher: benchi@weizoom.com
#editor: benchi
#editor: 师帅 2010.10.20

Feature: 在webapp中购买参与限时抢购活动的商品
	"""
		用户能在webapp中购买"参与限时抢购活动的商品"
		#editor: 王丽
		1、限时抢购活动的设置规则
			1）【限购广告语】：在商品名称后红字显示
			2）【活动时间】：开始结束时间只能选择今天及其之后的时间，结束时间必须在开始时间之后
			3）【会员等级】：设置什么等级的会员可以参加此次活动，下拉选项为：全部会员、会员等级中设置会员等级列表；选择"全部会员"或者单选一级会员
			4）【限购价格】：限购价格必须小于商品原价；多规格商品只能定义一个限购价格，不能根据不同规格定义限购价格
			5）【单人单次限购】：单人单次限购的数量；空为不限制
			6）【限购周期】：（？天），舍设置限购的周期，即设置多少天内只能购买一次；只要提交订单（订单状态不是"已取消"）就算购买一次；空为不限制
		2、限时抢购商品订单规则
			1）设置了"单人单次限购"的，在下订单的时候，数量只能增加到限购的数量，再增加数量不变，会给出提示"限购？件"
			2）购买多规格的有"单人单次限购"的限时抢购商品，在加入购物车时，不同规格分别限购，提交订单时，对限购数量不区分规格计算,
			订单中多规格商品数量的总和超过限购数量，给出提示"该订单内商品状态发生变化"
			3）会员既具有会员等级价又具有会员限时抢购权限的，限时抢购活动优先于会员等级价，会员看到的商品的价格是"限时抢购价格"，按照限时抢购的价格形成订单

		3、设置了“限时抢购”的商品，不能再设置“买赠”“优惠券活动”，三个活动是互斥的，只要设置了其中的一个活动，就不能再设置其他两个活动
	"""

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
			"model": {
				"models": {
					"standard": {
						"price": 100.00,
						"stock_type": "有限",
						"stocks": 3
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
	When jobs创建限时抢购活动::weapp
		"""
		[{
			"name": "商品1限时抢购",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品1",
			"member_grade": "全部",
			"count_per_purchase": 2,
			"promotion_price": 11.50
		}, {
			"name": "商品2限时抢购",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品2",
			"member_grade": "全部",
			"promotion_price": 2.10,
			"limit_period": 1
		}, {
			"name": "商品3限时抢购",
			"start_date": "2天前",
			"end_date": "1天前",
			"product_name": "商品3",
			"member_grade": "全部",
			"promotion_price": 3.10
		}]
		"""
	#会员等级
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
	Then jobs能获取会员等级列表::weapp
		"""
		[{
			"name": "普通会员",
			"discount": "10.0"
		}, {
			"name": "铜牌会员",
			"upgrade": "手动升级",
			"discount": "9.0"
		}, {
			"name": "银牌会员",
			"upgrade": "手动升级",
			"discount": "8.0"
		}, {
			"name": "金牌会员",
			"upgrade": "手动升级",
			"discount": "7.0"
		}]
		"""
	Given bill关注jobs的公众号
	And tom关注jobs的公众号
	And sam关注jobs的公众号
	And jobs登录系统::weapp
	When jobs更新'tom'的会员等级::weapp
		"""
		{
			"name": "tom",
			"member_rank": "铜牌会员"
		}
		"""
	When jobs更新'sam'的会员等级::weapp
		"""
		{
			"name": "sam",
			"member_rank": "银牌会员"
		}
		"""
	When jobs访问会员列表::weapp
	Then jobs获得会员列表默认查询条件::weapp
	Then jobs可以获得会员列表::weapp
		"""
			[{
				"name": "sam",
				"grade_name": "银牌会员"
			}, {
				"name": "tom",
				"grade_name": "铜牌会员"
			}, {
				"name": "bill",
				"grade_name": "普通会员"
			}]
		"""

@mall3 @promotion @mall.promotion @mall.webapp.promotion @robert.wip
Scenario: 1 购买单个限时抢购商品，限时抢购进行中
	没有设置限购周期，可以连续购买

	When bill访问jobs的webapp
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品1",
				"count": 2
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 23.00,
			"product_price": 23.00,
			"postage": 0.00,
			"integral_money":0.00,
			"coupon_money":0.00,
			"products": [{
				"name": "商品1",
				"count": 2,
				"promotion": {
					"promotioned_product_price": 11.50,
					"type": "flash_sale"
				}
			}]
		}
		"""
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
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
			"final_price": 11.50
		}
		"""

@mall3 @promotion @mall.promotion @mall.webapp.promotion @robert.wip @wip.bpwfs2
Scenario:2 购买单个限时抢购商品，限时抢购已过期（在购物车中是限时抢购商品，但，去提交订单时已经不是限时抢购商品）

	When bill访问jobs的webapp
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品3",
				"count": 1,
				"promotion": {
					"name": "商品3限时抢购"
				} 
			}]
		}
		"""
	Then bill获得创建订单失败的信息
		"""
		{
			"detail": [{
				"id": "商品3",
				"msg": "该活动已经过期",
				"short_msg": "已经过期"
			}]
		}
		"""

@mall3 @promotion @mall.promotion @mall.webapp.promotion
Scenario:3 购买单个限时抢购商品，限时抢购活动没开始，按原价下单

	Given jobs登录系统::weapp
	When jobs创建限时抢购活动::weapp
		"""
		{
			"name": "商品4限时抢购",
			"start_date": "1天后",
			"end_date": "3天后",
			"product_name": "商品4",
			"count_per_purchase": 2,
			"promotion_price": 11.50
		}
		"""
	When bill访问jobs的webapp
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品4",
				"count": 2
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 80.00
		}
		"""

@mall3 @promotion @mall.promotion @mall.webapp.promotion @robert.wip
Scenario:4 购买多个商品，带有限时抢购商品

	When bill访问jobs的webapp
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品1",
				"count": 2
			}, {
				"name": "商品2",
				"count": 1
			}, {
				"name": "商品4",
				"count": 1
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 65.10,
			"product_price": 65.10,
			"postage": 0.00,
			"integral_money":0.00,
			"coupon_money":0.00,
			"products": [{
				"name": "商品1",
				"count": 2,
				"promotion": {
					"promotioned_product_price": 11.50,
					"type": "flash_sale"
				}
			}, {
				"name": "商品2",
				"count": 1,
				"promotion": {
					"promotioned_product_price": 2.10,
					"type": "flash_sale"
				}
			}, {
				"name": "商品4",
				"count": 1,
				"price": 40.00,
				"promotion": null
			}]
		}
		"""

@mall3 @promotion @mall.promotion @mall.webapp.promotion @zy_fs05 @robert.wip
Scenario:5 购买单个限时抢购商品，超出库存限制
	第一次购买2个，成功；第二次购买2个，超出商品库存，确保缓存更新

	When bill访问jobs的webapp
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品1",
				"count": 2
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 23.00
		}
		"""
	When bill购买jobs的商品
		"""
		{
			"products": [{
				"name": "商品1",
				"count": 2
			}]
		}
		"""
	Then bill获得创建订单失败的信息
		"""
		{
			"detail": [{
				"id": "商品1",
				"msg": "有商品库存不足，请重新下单",
				"short_msg": "库存不足"
			}]
		}
		"""

@mall3 @promotion @mall.promotion @mall.webapp.promotion @zy_fs06 @robert.wip
Scenario:6 购买单个限时抢购商品，未超过库存限制，但超过单次购买限制

	Given jobs登录系统::weapp
	When jobs创建限时抢购活动::weapp
		"""
		{
			"name": "商品4限时抢购",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品4",
			"count_per_purchase": 2,
			"promotion_price": 11.50
		}
		"""
	When bill访问jobs的webapp
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品4",
				"count": 2
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 23.00
		}
		"""
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品4",
				"count": 3
			}]
		}
		"""
	Then bill获得创建订单失败的信息'限购2件'

@mall3 @promotion @mall.promotion @mall.webapp.promotion @robert.wip @wip.bpwfs7
Scenario:7 在限购周期内连续购买限时抢购商品

	When bill访问jobs的webapp
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品2",
				"count": 1
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 2.10
		}
		"""
	When bill购买jobs的商品
		"""
		{
			"products": [{
				"name": "商品2",
				"count": 1
			}]
		}
		"""
	Then bill获得创建订单失败的信息
		"""
		{
			"detail": [{
				"id": "商品2",
				"msg": "在限购周期内不能多次购买",
				"short_msg": "限制购买"
			}]
		}
		"""

@mall3 @promotion @mall.promotion @mall.webapp.promotion @zy_fs08 @robert.wip
Scenario:8 购买多规格限时抢购商品
	Given jobs登录系统::weapp
	When jobs创建限时抢购活动::weapp
		"""
		{
			"name": "商品5限时抢购",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品5",
			"count_per_purchase": 2,
			"promotion_price": 11.50
		}
		"""
	When bill访问jobs的webapp
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品5",
				"count": 1,
				"model": "S"
			}, {
				"name": "商品5",
				"count": 1,
				"model": "M"
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 23.00
		}
		"""
	When bill购买jobs的商品
		"""
		{
			"products": [{
				"name": "商品5",
				"count": 2,
				"model": "S"
			}, {
				"name": "商品5",
				"count": 1,
				"model": "M"
			}]
		}
		"""
	Then bill获得创建订单失败的信息'限购2件'

@mall3 @promotion @mall.promotion @mall.webapp.promotion @zy_fs09 @robert.wip
Scenario:9 购买多规格限时抢购商品同时适用于积分规则

	Given jobs登录系统::weapp
	And jobs设定会员积分策略::weapp
		"""
		{
			"integral_each_yuan": 2,
			"use_ceiling": 50
		}
		"""


	When jobs创建限时抢购活动::weapp
		"""
		{
			"name": "商品5限时抢购",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品5",
			"count_per_purchase": 2,
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
			"integral_money":10.00,
			"integral":20,
			"products": [{
				"name": "商品5",
				"count": 1,
				"model": "S"
			}, {
				"name": "商品5",
				"count": 1,
				"model": "M"
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 10.00,
			"product_price": 20.00,
			"promotion_saved_money":60.00,
			"postage": 0.00,
			"integral_money":10.00,
			"integral":20,
			"coupon_money":0.00,
			"products": [{
				"name": "商品5",
				"count": 1,
				"model": "S"
			}, {
				"name": "商品5",
				"count": 1,
				"model": "M"
			}]
		}
		"""
	Then bill在jobs的webapp中拥有30会员积分

@mall3 @promotion @mall.promotion @mall.webapp.promotion @zy_fs10 @robert.wip
Scenario:10 购买单个限时抢购商品，购买时活动进行中，提交订单时，该活动被商家手工结束

	Given jobs登录系统::weapp
	When jobs创建限时抢购活动::weapp
		"""
		{
			"name": "商品4限时抢购",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品4",
			"count_per_purchase": 2,
			"promotion_price": 11.50
		}
		"""
	And jobs'结束'促销活动'商品4限时抢购'::weapp

	When bill访问jobs的webapp
	And bill购买jobs的商品
		"""
		{
			"products": [{
				"name": "商品4",
				"count": 1,
				"promotion": {
					"name": "商品4限时抢购"
				}
			}]
		}
		"""

	Then bill获得创建订单失败的信息
		"""
		{
			"detail": [{
				"id": "商品4",
				"msg": "该活动已经过期",
				"short_msg": "已经过期"
			}]
		}
		"""


#雪静
@mall3 @promotion @mall.promotion @mall.webapp.promotion
Scenario:11 购买单个限时抢购商品，未支付然后取消订单，还可以再次下单
	有限购周期和限购数量设置

	Given jobs登录系统::weapp
	When jobs创建限时抢购活动::weapp
		"""
		{
			"name": "商品4限时抢购",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品4",
			"count_per_purchase": 2,
			"promotion_price": 11.50,
			"limit_period": 1
		}
		"""
	When bill访问jobs的webapp
	And bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品4",
				"count": 1,
				"promotion": {
					"name": "商品4限时抢购"
				}
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 11.50
		}
		"""
	Given jobs登录系统::weapp
	Then jobs可以获得最新订单详情::weapp
		"""
		{
			"status": "待支付",
			"final_price": 11.50,
			"actions": ["取消订单", "支付","修改价格"]
		}
		"""
	When jobs'取消'最新订单::weapp
		"""
		 {
		 	"reason": "不想要了"
		 }
		"""
	Then jobs可以获得最新订单详情::weapp
		"""
		{
			"status": "已取消",
			"final_price": 11.50,
			"actions": []
		}
		"""
	When bill访问jobs的webapp
	And bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品4",
				"count": 2,
				"promotion": {
					"name": "商品4限时抢购"
				}
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 23.00
		}
		"""
	Given jobs登录系统::weapp
	Then jobs可以获得最新订单详情::weapp
		"""
		{
			"status": "待支付",
			"final_price": 23.00,
			"actions": ["取消订单", "支付","修改价格"]
		}
		"""

#后续补充会员等级价.师帅
@mall3 @promotion
Scenario:12 不同等级的会员购买有会员价同时有限时抢购的商品（限时抢购优先于会员价）
	When jobs更新商品'商品1'::weapp
		"""
		{
			"is_member_product": "on",
			"model": {
				"models": {
					"standard": {
						"stock_type": "有限",
						"stocks": 30,
						"price": 100.00
					}
				}
			}
		}
		"""
	When bill访问jobs的webapp
	And bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品1",
				"count": 2
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 23.00,
			"product_price": 23.00,
			"postage": 0.00,
			"integral_money":0.00,
			"coupon_money":0.00,
			"products": [{
				"name": "商品1",
				"count": 2,
				"price": 11.50,
				"promotion": {
					"promotioned_product_price": 11.50,
					"type": "flash_sale"
				}
			}]
		}
		"""
	When tom访问jobs的webapp
	And tom购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品1",
				"count": 2
			}]
		}
		"""
	Then tom成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 23.00,
			"product_price": 23.00,
			"postage": 0.00,
			"integral_money":0.00,
			"coupon_money":0.00,
			"products": [{
				"name": "商品1",
				"count": 2,
				"promotion": {
					"promotioned_product_price": 11.50,
					"type": "flash_sale"
				}
			}]
		}
		"""

@mall3 @promotion
Scenario:13 不同等级的会员购买有会员价同时有会员等级限时抢购的商品（限时抢购优先于会员价）
	When jobs更新商品'商品1'::weapp
		"""
		{
			"is_member_product": "on",
			"model": {
				"models": {
					"standard": {
						"stock_type": "有限",
						"stocks": 30,
						"price": 100.00
					}
				}
			}
		}
		"""
	And jobs'结束'促销活动'商品1限时抢购'::weapp
	And jobs创建限时抢购活动::weapp
	"""
		[{
			"name": "商品1限时抢购-50",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品1",
			"member_grade": "银牌会员",
			"promotion_price": 50.00
		}]
	"""
	When bill访问jobs的webapp
	And bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品1",
				"count": 2
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 200.00,
			"product_price": 200.00,
			"postage": 0.00,
			"integral_money":0.00,
			"coupon_money":0.00,
			"products": [{
				"name": "商品1",
				"count": 2
			}]
		}
		"""
	When tom访问jobs的webapp
	And tom购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品1",
				"count": 2
			}]
		}
		"""
	Then tom成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 180.00,
			"product_price": 180.00,
			"postage": 0.00,
			"integral_money":0.00,
			"coupon_money":0.00,
			"products": [{
				"name": "商品1",
				"price": 90.00,
				"count": 2
			}]
		}
		"""
	When sam访问jobs的webapp
	And sam购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品1",
				"count": 2
			}]
		}
		"""
	Then sam成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 100.00,
			"product_price": 100.00,
			"postage": 0.00,
			"integral_money":0.00,
			"coupon_money":0.00,
			"products": [{
				"name": "商品1",
				"count": 2,
				"promotion": {
					"promotioned_product_price": 50.00,
					"type": "flash_sale"
				}
			}]
		}
		"""

@mall3 @promotion
Scenario:14 不同等级的会员购买原价有会员等级限时抢购的商品
	When jobs更新商品'商品1'::weapp
		"""
		{
			"is_member_product": "off",
			"model": {
				"models": {
					"standard": {
						"price": 100.00,
						"stock_type": "有限",
						"stocks": 30
					}
				}
			}
		}
		"""
	And jobs'结束'促销活动'商品1限时抢购'::weapp
	And jobs创建限时抢购活动::weapp
		"""
		[{
			"name": "商品1限时抢购-50",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品1",
			"member_grade": "银牌会员",
			"promotion_price": 50.00
		}]
		"""
	When bill访问jobs的webapp
	And bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品1",
				"count": 2
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 200.00,
			"product_price": 200.00,
			"postage": 0.00,
			"integral_money":0.00,
			"coupon_money":0.00,
			"products": [{
				"name": "商品1",
				"count": 2
			}]
		}
		"""
	When tom访问jobs的webapp
	And tom购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品1",
				"count": 2
			}]
		}
		"""
	Then tom成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 200.00,
			"product_price": 200.00,
			"postage": 0.00,
			"integral_money":0.00,
			"coupon_money":0.00,
			"products": [{
				"name": "商品1",
				"count": 2
			}]
		}
		"""
	When sam访问jobs的webapp
	And sam购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品1",
				"count": 2
			}]
		}
		"""
	Then sam成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 100.00,
			"product_price": 100.00,
			"postage": 0.00,
			"integral_money":0.00,
			"coupon_money":0.00,
			"products": [{
				"name": "商品1",
				"count": 2,
				"promotion": {
					"promotioned_product_price": 50.00,
					"type": "flash_sale"
				}
			}]
		}
		"""

@mall3 @promotion @robert.wip
Scenario:15 购买多规格限时抢购商品同时适用于积分规则和会员等级

	Given jobs登录系统::weapp
	And jobs设定会员积分策略::weapp
		"""
		{
			"integral_each_yuan": 2,
			"use_ceiling": 50
		}
		"""
	When jobs更新商品'商品5'::weapp
		"""
		{
			"is_member_product": "on",
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
		}
		"""
	When jobs创建限时抢购活动::weapp
		"""
		{
			"name": "商品5限时抢购",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品5",
			"member_grade": "银牌会员",
			"promotion_price": 10.00
		}
		"""
	When bill访问jobs的webapp
	When bill获得jobs的100会员积分
	Then bill在jobs的webapp中拥有100会员积分
	When tom获得jobs的100会员积分
	Then tom在jobs的webapp中拥有100会员积分
	When sam获得jobs的100会员积分
	Then sam在jobs的webapp中拥有100会员积分

	When bill访问jobs的webapp
	And bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"integral_money":40.00,
			"integral":80.00,
			"products": [{
				"name": "商品5",
				"count": 1,
				"model": "S"
			}, {
				"name": "商品5",
				"count": 1,
				"model": "M"
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 40.00,
			"product_price": 80.00,
			"promotion_saved_money":0.00,
			"postage": 0.00,
			"integral_money":40.00,
			"integral":80.00,
			"coupon_money":0.00,
			"products": [{
				"name": "商品5",
				"count": 1,
				"model": "S"
			}, {
				"name": "商品5",
				"count": 1,
				"model": "M"
			}]
		}
		"""
	Then bill在jobs的webapp中拥有20会员积分
	
	When tom访问jobs的webapp
	And tom购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"integral_money":36.00,
			"integral":72.00,
			"products": [{
				"name": "商品5",
				"count": 1,
				"model": "S"
			}, {
				"name": "商品5",
				"count": 1,
				"model": "M"
			}]
		}
		"""
	Then tom成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 36.00,
			"product_price": 72.00,
			"promotion_saved_money":0.00,
			"postage": 0.00,
			"integral_money":36.00,
			"integral":72.00,
			"coupon_money":0.00,
			"products": [{
				"name": "商品5",
				"count": 1,
				"model": "S"
			}, {
				"name": "商品5",
				"count": 1,
				"model": "M"
			}]
		}
		"""
	Then tom在jobs的webapp中拥有28会员积分

	When sam访问jobs的webapp
	And sam购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"integral_money":10.00,
			"integral":20,
			"products": [{
				"name": "商品5",
				"count": 1,
				"model": "S"
			}, {
				"name": "商品5",
				"count": 1,
				"model": "M"
			}]
		}
		"""
	Then sam成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 10.00,
			"product_price": 20.00,
			"promotion_saved_money": 60.00,
			"postage": 0.00,
			"integral_money":10.00,
			"integral":20,
			"coupon_money":0.00,
			"products": [{
				"name": "商品5",
				"count": 1,
				"model": "S"
			}, {
				"name": "商品5",
				"count": 1,
				"model": "M"
			}]
		}
		"""
	Then sam在jobs的webapp中拥有80会员积分


#根据需求9241后续添加.雪静
@mall3 @sherry @ztq
Scenario:16 普通商品设置限时抢购活动的价格和商品原价相等
	普通商品设置限时抢购活动的价格和商品原价相等
	1.bill进行购买，商品详情页优惠里不显示"限时抢购-已优惠0元"，其余保持不变
	2.bill把商品16添加到购物车，购物车保持不变

	Given jobs登录系统::weapp
	And jobs已添加商品::weapp
		"""
		[{
			"name": "商品16",
			"price": 100.00
		}]
		"""
	When jobs创建限时抢购活动::weapp
		"""
		[{
			"name": "限时抢购优惠0元",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品16",
			"member_grade": "全部",
			"count_per_purchase": 2,
			"promotion_price": 100.00
		}]
		"""
	When bill访问jobs的webapp
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品16",
				"count": 1
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 100.00,
			"product_price": 100.00,
			"postage": 0.00,
			"integral_money":0.00,
			"coupon_money":0.00,
			"products": [{
				"name": "商品16",
				"count": 1,
				"promotion": {
					"promotioned_product_price": 100.00,
					"type": "flash_sale"
				}
			}]
		}
		"""
	When bill加入jobs的商品到购物车
		"""
		[{
			"name": "商品16",
			"count": 1
		}]
		"""
	Then bill能获得购物车
		"""
		{
			"product_groups": [{
				"promotion": {
					"type": "flash_sale",
					"result": {
						"saved_money": 0.00
					}
				},
				"can_use_promotion": true,
				"products": [{
					"name": "商品16",
					"price": 100.00,
					"count": 1
				}]
			}],
			"invalid_products": []
		}
		"""

@mall3 @sherry @ztq
Scenario:17 多规格商品设置限时抢购活动的价格和商品最小规格原价相等
	多规格商品设置限时抢购活动的价格和商品最小规格原价相等
	1.bill选择原价等于限时抢购价格的规格，商品详情页优惠里不显示"限时抢购-已优惠0元"，其余保持不变
	2.bill选择原价大于限时抢购价格的规格，商品详情页保持不变
	3.bill把多规格商品添加到购物车，购物车保持不变

	Given jobs登录系统::weapp
	And jobs已添加商品::weapp
		"""
		[{
			"name": "商品17",
			"is_enable_model": "启用规格",
			"model": {
				"models":{
					"M": {
						"price": 10.00,
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
	When jobs创建限时抢购活动::weapp
		"""
		[{
			"name": "多规格限时抢购优惠0元",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品17",
			"member_grade": "全部",
			"count_per_purchase": 2,
			"promotion_price": 10.00
		}]
		"""
	When bill访问jobs的webapp
	When bill购买jobs的商品
		"""
		{
			"pay_type": "微信支付",
			"products": [{
				"name": "商品17",
				"model": "M",
				"count": 1
			}, {
				"name": "商品17",
				"model": "S",
				"count": 1
			}]
		}
		"""
	Then bill成功创建订单
		"""
		{
			"status": "待支付",
			"final_price": 20.00,
			"product_price": 20.00,
			"postage": 0.00,
			"integral_money":0.00,
			"coupon_money":0.00,
			"products": [{
				"name": "商品17",
				"model": "M",
				"count": 1,
				"promotion": {
					"promotioned_product_price": 10.00,
					"type": "flash_sale"
				}
			}, {
				"name": "商品17",
				"model": "S",
				"count": 1,
				"promotion": {
					"promotioned_product_price": 10.00,
					"type": "flash_sale"
				}
			}]
		}
		"""
	When bill加入jobs的商品到购物车
		"""
		[{
			"name": "商品17",
			"model": {
				"models":{
					"M": {
						"count": 1
					}
				}
			}
		}, {
			"name": "商品17",
			"model": {
				"models":{
					"S": {
						"count": 1
					}
				}
			}
		}]
		"""
	Then bill能获得购物车
		"""
		{
			"product_groups": [{
				"promotion": {
					"type": "flash_sale",
					"result": {
						"saved_money": 0.00
					}
				},
				"can_use_promotion": true,
				"products": [{
					"name": "商品17",
					"price": 10.00,
					"model": "M",
					"count": 1
				}]
			}, {
				"promotion": {
					"type": "flash_sale",
					"result": {
						"saved_money": 30.00
					}
				},
				"can_use_promotion": true,
				"products": [{
					"name": "商品17",
					"price": 10.00,
					"model": "S",
					"count": 1
				}]
			}],
			"invalid_products": []
		}
		"""




