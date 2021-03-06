# watcher: fengxuejing@weizoom.com,wangli@weizoom.com,benchi@weizoom.com
# __edit__ : "benchi"
#editor:王丽 2015.10.20
#editor:robert 2015.12.08
#超出限购数量的验证是在前端进行的，故在ui的feathure进行实现
Feature: 添加限时抢购商品到购物车中
"""
	bill能在webapp中将jobs添加的"商品"放入购物车
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
			"price": 30.00
		}, {
			"name": "商品2",
			"price": 5.00
		}, {
			"name": "商品3",
			"is_enable_model": "启用规格",
			"model": {
				"models":{
					"M":{
						"price": 7.00,
						"stock_type": "有限",
						"stocks": 2
					},
					"S":{
						"price": 8.00,
						"stock_type": "无限"
					}
				}
			}
		}, {
			"name": "商品4",
			"is_enable_model": "启用规格",
			"model":{
				"models":{
					"M":{
						"price": 9.00,
						"stock_type": "无限"
					}
				}
			}
		}, {
			"name": "商品5",
			"is_enable_model": "启用规格",
			"model":{
				"models":{
					"S":{
						"price": 10.00,
						"stock_type": "无限"
					}
				}
			}
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
			"promotion_price": 11.50
		}, {
			"name": "商品2限时抢购",
			"start_date": "1天后",
			"end_date": "2天后",
			"product_name": "商品2",
			"promotion_price": 2.10
		}, {
			"name": "商品3限时抢购",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品3",
			"promotion_price": 3.10
		}, {
			"name": "商品4限时抢购",
			"start_date": "前天",
			"end_date": "昨天",
			"product_name": "商品4",
			"promotion_price": 4.10
		}]
		"""
	And bill关注jobs的公众号

@mall3 @buy @cart   @mall.webapp @mall.webapp.shopping_cart
Scenario: 1 放入多个商品到购物车，商品的限时抢购活动为进行中
	bill将商品放入到购物车后
	1. bill能看到购物车中商品的详情
	
	When bill访问jobs的webapp
	And bill加入jobs的商品到购物车
		"""
		[{
			"name": "商品1",
			"count": 1
		}, {
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
						"count": 2
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
						"saved_money": 18.50
					}
				},
				"can_use_promotion": true,
				"products": [{
					"name": "商品1",
					"price": 11.50,
					"count": 1
				}]
			}, {
				"promotion": {
					"type": "flash_sale",
					"result": {
						"saved_money": 3.90
					}
				},
				"can_use_promotion": true,
				"products": [{
					"name": "商品3",
					"price": 3.10,
					"count": 1,
					"model": "M"
				}]
			}, {
				"promotion": {
					"type": "flash_sale",
					"result": {
						"saved_money": 4.90
					}
				},
				"can_use_promotion": true,
				"products": [{
					"name": "商品3",
					"price": 3.10,
					"count": 2,
					"model": "S"
				}]
			}],
			"invalid_products": []
		}
		"""

@mall3 @buy @cart   @mall.webapp @mall.webapp.shopping_cart
Scenario:2 放入多个商品到购物车，商品的限时抢购活动包括未开始、进行中和已结束
	bill将商品放入到购物车后
	1. bill能看到购物车中商品的详情
	
	When bill访问jobs的webapp
	And bill加入jobs的商品到购物车
		"""
		[{
			"name": "商品1",
			"count": 1
		}, {
			"name": "商品2",
			"count": 1
		}, {
			"name": "商品4",
			"model": {
				"models":{
					"M": {
						"count": 2
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
						"saved_money": 18.50
					}
				},
				"can_use_promotion": true,
				"products": [{
					"name": "商品1",
					"price": 11.50,
					"count": 1
				}]
			}, {
				"promotion": null,
				"can_use_promotion": false,
				"products": [{
					"name": "商品2",
					"price": 5.00,
					"count": 1
				}, {
					"name": "商品4",
					"price": 9.00,
					"count": 2
				}]
			}],
			"invalid_products": []
		}
		"""

@mall3 @buy @cart   @mall.webapp @mall.webapp.shopping_cart
Scenario:3 放入多规格商品到购物车，无限购

	Given jobs登录系统::weapp
	And jobs已添加商品::weapp
		"""
		[{
			"name": "商品7",
			"is_enable_model": "启用规格",
			"model": {
				"models":{
					"M": {
						"price": 100.00,
						"stock_type": "无限"
					},
					"S": {
						"price": 100.00,
						"stock_type": "无限"
					}
				}
			}
		}]
		"""
	When jobs创建限时抢购活动::weapp
		"""
		{
			"name": "商品7限时抢购",
			"start_date": "1天前",
			"end_date": "3天后",
			"product_name": "商品7",
			"promotion_price": 10.00
		}
		"""
	
	When bill访问jobs的webapp
	And bill加入jobs的商品到购物车
		"""
		[{
			"name": "商品7",
			"model": {
				"models":{
					"M": {
						"count": 1
					}
				}
			}
		}, {
			"name": "商品7",
			"model": {
				"models":{
					"S": {
						"count": 2
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
					"name": "商品7",
					"price": 10.00,
					"count": 1,
					"model": "M"
				}]
			}, {
				"promotion": {
					"type": "flash_sale",
					"result": {
						"saved_money": 90.00
					}
				},
				"can_use_promotion": true,
				"products": [{
					"name": "商品7",
					"price": 10.00,
					"count": 2,
					"model": "S"
				}]
			}],
			"invalid_products": []
		}
		"""
