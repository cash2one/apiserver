# watcher: benchi@weizoom.com, fengxuejing@weizoom.com
#editor:robert 2015.12.07

Feature: 添加普通商品，促销商品到购物车中
	bill能在webapp中将jobs添加的"普通商品，促销商品"放入购物车

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
			"price": 100.00
		}, {
			"name": "商品2",
			"price": 200.00
		}, {
			"name": "商品3",
			"is_enable_model": "启用规格",
			"model": {
				"models":{
					"M": {
						"price": 300.00,
						"stock_type": "无限"
					},
					"S": {
						"price": 300.00,
						"stock_type": "无限"
					}
				}
			}
		}, {
			"name": "商品4",
			"price":400.00
		}]	
		"""

	When jobs创建限时抢购活动::weapp
		"""
		[{
			"name": "商品1限时抢购",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品1",
			"count_per_purchase": 2,
			"promotion_price": 10.00
		}]

		"""
	When jobs创建买赠活动::weapp
		"""
		[{
			"name": "商品2买二赠一",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品2",
			"premium_products": [{
				"name": "商品4",
				"count": 1
			}],
			"count": 2,
			"is_enable_cycle_mode": true
		}]
		"""
	And bill关注jobs的公众号
	And tom关注jobs的公众号

@mall3 @mall.webapp @mall.webapp.shopping_cart
#购买流程.购物车
Scenario:1 放入多个商品（商品1,2,3）到购物车，商品1是限时抢购活动，商品2是买赠活动，商品3是多规格商品，没有参加任何活动
	jobs添加商品后
	1. bill能在webapp中将jobs添加的商品放入购物车
	2. tom的购物车不受bill操作的影响
	注意：总价和总商品数量是在前台计算，对它们的测试放到ui测试中，这里无法测试

	When bill访问jobs的webapp
	And bill加入jobs的商品到购物车
		"""
		[{
			"name": "商品1",
			"count": 1
		},{
			"name": "商品2",
			"count": 2
		},{
			"name": "商品3",
			"model": {
				"models":{
					"M": {
						"count": 1
					}
				}
			}
		}, {
			"name": "商品3",
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
						"saved_money": 90.00
					}
				},
				"can_use_promotion": true,
				"products": [{
					"name": "商品1",
					"price": 10.00,
					"count": 1
				}]
			}, {
				"promotion": {
					"type": "premium_sale",
					"result": {
						"premium_products": [{
							"name": "商品4",
							"premium_count": 1
						}]
					}
				},
				"can_use_promotion": true,
				"products": [{
					"name": "商品2",
					"price": 200.00,
					"count": 2
				}]
			}, {
				"products": [{
					"name": "商品3",
					"price": 300.00,
					"count": 1,
					"model": "M"
				}, {
					"name": "商品3",
					"price": 300.00,
					"count": 1,
					"model": "S"
				}]
			}],
			"invalid_products": []
		}
		"""

	When tom访问jobs的webapp
	Then tom能获得购物车
		"""
		{
			"product_groups": [],
			"invalid_products": []
		}
		"""

@mall3 @mall.webapp @mall.webapp.shopping_cart
Scenario:2 买赠活动商品，加入购物车的主商品数量小于买赠活动主商品的买赠基数数量
	Given jobs登录系统::weapp
	When jobs已添加商品::weapp
		"""
		[{
			"name": "商品5",
			"price": 100.00
		},{
			"name": "商品6",
			"price": 50.00,
			"stock_type": "有限",
			"stocks": 2
		}]
		"""
	When jobs创建买赠活动::weapp
		"""
		[{
			"name": "商品5买三赠一",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品5",
			"premium_products": [{
				"name": "商品6",
				"count": 1
			}],
			"count": 3,
			"is_enable_cycle_mode": false
		}]
		"""
	When bill访问jobs的webapp
	And bill加入jobs的商品到购物车
		"""
		[{
			"name": "商品5",
			"count": 2
		}]
		"""
	Then bill能获得购物车
		"""
		{
			"product_groups": [{

				"products": [{
					"name": "商品5",
					"price": 100.00,
					"count": 2
				}]
			}],
			"invalid_products": []
		}
		"""
