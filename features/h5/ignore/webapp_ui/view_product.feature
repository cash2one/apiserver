# __author__ : "冯雪静"
#说明：ui的feature暂时无法实现，2016.01.19移除到ignore文件夹下

@func:webapp.modules.mall.views.list_products
Feature: 在webapp中浏览商品
	bill能在webapp中看到jobs添加的"商品"
	"""
	准备数据：1.商品分类，2.商品规格，3.会员等级，4.商品，5.限时抢购活动，6.会员
	1.浏览商品
	2.浏览商品列表
	3.浏览商品分类
	4.限时抢购优先于会员价
	5.买赠活动优先于会员价
	6.浏览仅售禁售商品 【2016-09-01需求新增】
	"""

Background:
	Given jobs登录系统
	And jobs已添加商品分类
		"""
		[{
			"name": "分类1"
		}, {
			"name": "分类2"
		}, {
			"name": "分类3"
		}]
		"""
	And jobs已添加商品规格
		"""
		[{
			"name": "颜色",
			"type": "图片",
			"values": [{
				"name": "黑色",
				"image": "/standard_static/test_resource_img/hangzhou1.jpg"
			}, {
				"name": "白色",
				"image": "/standard_static/test_resource_img/hangzhou2.jpg"
			}]
		}, {
			"name": "尺寸",
			"type": "文字",
			"values": [{
				"name": "M"
			}, {
				"name": "S"
			}]
		}]
		"""
	When jobs添加会员等级
		"""
		[{
			"name": "铜牌会员",
			"upgrade": "手动升级",
			"discount": "9"
		}]
		"""
	Given jobs已添加商品
	#商品1：开起了会员价，多规格，起购数量 商品2：是限时抢购商品，商品3：普通商品，商品5：起购数量
		"""
		[{
			"name": "商品1",
			"promotion_title": "促销的东坡肘子",
			"categories": "分类1,分类2,分类3",
			"detail": "东坡肘子的详情",
			"status": "在售",
			"purchase_count": 3,
			"is_member_product": "on",
			"swipe_images": [{
				"url": "/standard_static/test_resource_img/hangzhou1.jpg"
			}, {
				"url": "/standard_static/test_resource_img/hangzhou2.jpg"
			}, {
				"url": "/standard_static/test_resource_img/hangzhou3.jpg"
			}],
			"is_enable_model": "启用规格",
			"model": {
				"models": {
					"黑色 S": {
						"price": 20.00,
						"stock_type": "有限",
						"stocks": 3
					},
					"白色 S": {
						"price": 10.00,
						"stock_type": "无限"
					}
				}
			}
		}, {
			"name": "商品2",
			"category": "分类1",
			"detail": "叫花鸡的详情",
			"status": "在售",
			"swipe_images": [{
				"url": "/standard_static/test_resource_img/hangzhou2.jpg"
			}],
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
			"name": "商品3",
			"category": "",
			"detail": "叫花鸡的详情",
			"status": "在售",
			"swipe_images": [{
				"url": "/standard_static/test_resource_img/hangzhou2.jpg"
			}],
			"model": {
				"models": {
					"standard": {
						"price": 12.00,
						"stock_type": "有限",
						"stocks": 3
					}
				}
			}
		}, {
			"name": "商品4",
			"category": "",
			"detail": "叫花鸡的详情",
			"status": "待售",
			"swipe_images": [{
				"url": "/standard_static/test_resource_img/hangzhou2.jpg"
			}],
			"model": {
				"models": {
					"standard": {
						"price": 15.00,
						"stock_type": "无限"
					}
				}
			}
		}, {
			"name": "商品5",
			"category": "",
			"detail": "",
			"status": "在售",
			"purchase_count": 3,
			"swipe_images": [{
				"url": "/standard_static/test_resource_img/hangzhou2.jpg"
			}],
			"model": {
				"models": {
					"standard": {
						"price": 15.00,
						"stock_type": "有限",
						"stocks": 2
					}
				}
			}
		}]
		"""
	When jobs创建限时抢购活动
		"""
		[{
			"name": "商品2限时抢购",
			"promotion_title":"限时抢购",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name":"商品2",
			"member_grade": "铜牌会员",
			"count_per_purchase": 1,
			"promotion_price": 50.00,
			"limit_period": 1
		}]
		"""
	Given bill关注jobs的公众号
	And tom关注jobs的公众号
	Given jobs登录系统
	When jobs更新'bill'的会员等级
		"""
		{
			"name": "bill",
			"member_rank": "铜牌会员"
		}
		"""
	Then jobs可以获得会员列表
		"""
		[{
			"name": "tom",
			"member_rank": "普通会员"
		}, {
			"name": "bill",
			"member_rank": "铜牌会员"
		}]
		"""

@product @ui @ProductDetail
Scenario: 1 浏览商品
	jobs添加商品后
	1. bill能在webapp中看到jobs添加的商品
	2. tom能在webapp中看到jobs添加的商品

	When bill访问jobs的webapp
	And bill浏览jobs的webapp的'商品1'商品页
	#享受会员价的会员能获取商品原价和会员价
	#设置了起购数量3，商品详情页提示“至少购买3件”
	#库存和起购数量相等时，点击加数量时提示“库存不足”
	Then webapp页面标题为'商品1'
	And bill获得webapp商品
		"""
		{
			"name": "商品1",
			"promotion_title": "促销的东坡肘子",
			"detail": "东坡肘子的详情",
			"swipe_images": [{
				"url": "/standard_static/test_resource_img/hangzhou1.jpg"
			}, {
				"url": "/standard_static/test_resource_img/hangzhou2.jpg"
			}, {
				"url": "/standard_static/test_resource_img/hangzhou3.jpg"
			}],
			"model": {
				"models": {
					"黑色 S": {
						"price": 20.00,
						"member_price": 18.00,
						"stocks": 3,
						"count": 3,
						"提示信息": "库存不足",
						"提示信息": "至少购买3件"
					},
					"白色 S": {
						"price": 10.00,
						"member_price": 9.00,
						"count": 3,
						"提示信息": "至少购买3件"
					}
				}
			}
		}
		"""
	When bill浏览jobs的webapp的'商品2'商品页
	#享受限时抢购的会员获取的是限时抢购价
	#购买的数量等于显示抢购数量时，点击加数量提示“限购一件”
	Then webapp页面标题为'商品2'
	And bill获得webapp商品
		"""
		{
			"name": "商品2",
			"detail": "限时抢购",
			"swipe_images": [{
				"url": "/standard_static/test_resource_img/hangzhou2.jpg"
			}],
			"model": {
				"models": {
					"standard": {
						"price": 50.00,
						"count": 1,
						"提示信息": "限购一件"
					}
				}
			}
		}
		"""
	When bill浏览jobs的webapp的'商品3'商品页
	Then webapp页面标题为'商品3'
	And bill获得webapp商品
		"""
		{
			"name": "商品3",
			"detail": "叫花鸡的详情",
			"swipe_images": [{
				"url": "/standard_static/test_resource_img/hangzhou2.jpg"
			}],
			"model": {
				"models": {
					"standard": {
						"price": 12.00,
						"stocks": 3
					}
				}
			}
		}
		"""
	When bill浏览jobs的webapp的'商品5'商品页
	#起购数量大于库存数量时提示“库存不足”，“至少购买几件”
	#点击加入购物车和立即购买时提示“库存不足”
	Then webapp页面标题为'商品5'
	And bill获得webapp商品
		"""
		{
			"name": "商品5",
			"swipe_images": [{
				"url": "/standard_static/test_resource_img/hangzhou2.jpg"
			}],
			"model": {
				"models": {
					"standard": {
						"price": 15.00,
						"count": 3,
						"提示信息": "库存不足",
						"提示信息": "至少购买3件"
					}
				}
			}
		}
		"""
	When bill点击"加入购物车"
	Then bill获得错误提示'库存不足'
	When bill点击"立即购买"
	Then bill获得错误提示'库存不足'

	When tom访问jobs的webapp
	And tom浏览jobs的webapp的'商品1'商品页
	Then webapp页面标题为'商品1'
	And tom获得webapp商品
		"""
		{
			"name": "商品1",
			"promotion_title": "促销的东坡肘子",
			"detail": "东坡肘子的详情",
			"swipe_images": [{
				"url": "/standard_static/test_resource_img/hangzhou1.jpg"
			}, {
				"url": "/standard_static/test_resource_img/hangzhou2.jpg"
			}, {
				"url": "/standard_static/test_resource_img/hangzhou3.jpg"
			}],
			"model": {
				"models": {
					"黑色 S": {
						"price": 20.00,
						"stocks": 3,
						"count": 3,
						"提示信息": "库存不足",
						"提示信息": "至少购买3件"
					},
					"白色 S": {
						"price": 10.00,
						"count": 3,
						"提示信息": "至少购买3件"
					}
				}
			}
		}
		"""
	When tom浏览jobs的webapp的'商品2'商品页
	#有限商品，库存和购买数量相等时，点击加数量提示“库存不足”
	Then webapp页面标题为'商品2'
	And tom获得webapp商品
		"""
		{
			"name": "商品2",
			"detail": "叫花鸡的详情",
			"swipe_images": [{
				"url": "/standard_static/test_resource_img/hangzhou2.jpg"
			}],
			"model": {
				"models": {
					"standard": {
						"price": 100.00,
						"count": 3,
						"提示信息": "库存不足"
					}
				}
			}
		}
		"""
	When tom浏览jobs的webapp的'商品3'商品页
	Then webapp页面标题为'商品3'
	And tom获得webapp商品
		"""
		{
			"name": "商品3",
			"detail": "叫花鸡的详情",
			"swipe_images": [{
				"url": "/standard_static/test_resource_img/hangzhou2.jpg"
			}],
			"model": {
				"models": {
					"standard": {
						"price": 12.00,
						"stocks": 3
					}
				}
			}
		}
		"""

@product @ui @ProductList
Scenario: 2 浏览商品列表
	jobs添加商品后
	1. bill获得webapp商品列表，商品按添加顺序倒序排序
	2. tom获得webapp商品列表，商品按添加顺序倒序排序

	When bill访问jobs的webapp
	And bill浏览jobs的webapp的'全部'商品列表页
	#有会员价的会员获取商品列表时是会员价
	#享受限时抢购的会员获取商品列表是限时抢购价
	Then webapp页面标题为'商品列表'
	And bill获得webapp商品列表
		"""
		[{
			"name": "商品5",
			"price": 15.00
		}, {
			"name": "商品3",
			"price": 12.00
		}, {
			"name": "商品2",
			"price": 50.00
		}, {
			"name": "商品1",
			"price": 9.00
		}]
		"""
	When tom访问jobs的webapp
	And tom浏览jobs的webapp的'全部'商品列表页
	Then webapp页面标题为'商品列表'
	And tom获得webapp商品列表
		"""
		[{
			"name": "商品5",
			"price": 15.00
		}, {
			"name": "商品3",
			"price": 12.00
		}, {
			"name": "商品2",
			"price": 100.00
		}, {
			"name": "商品1",
			"price": 10.00
		}]
		"""

@product @ui @ProductList
Scenario: 3 浏览商品分类
	jobs添加商品后
	1. bill获得webapp商品列表，商品按添加顺序倒序排序
	2. tom获得webapp商品列表，商品按添加顺序倒序排序

	When bill访问jobs的webapp
	And bill浏览jobs的webapp的'分类1'商品列表页
	Then webapp页面标题为'商品列表'
	And bill获得webapp商品列表
		"""
		[{
			"name": "商品2",
			"price": 50.00
		}, {
			"name": "商品1",
			"price": 9.00
		}]
		"""
	When tom访问jobs的webapp
	And tom浏览jobs的webapp的'分类1'商品列表页
	Then webapp页面标题为'商品列表'
	And tom获得webapp商品列表
		"""
		[{
			"name": "商品2",
			"price": 100.00
		}, {
			"name": "商品1",
			"price": 10.00
		}]
		"""

#补充：张三香 2015.11.09
	#针对微商城bug5848-商品同时参与买赠和会员折扣时，手机端商品详情页显示错误（不应显示会员价）
@product @ui @ProductList
Scenario:4 查看商品详情页（买赠和会员价同时，买赠优先）
	Given jobs登录系统
	And jobs已添加商品
		"""
		[{
			"name": "买赠和会员价1",
			"promotion_title": "铜牌买赠和会员价",
			"detail": "买赠和会员价1的详情",
			"status": "在售",
			"is_member_product": "on",
			"swipe_images": [{
				"url": "/standard_static/test_resource_img/hangzhou1.jpg"
			}, {
				"url": "/standard_static/test_resource_img/hangzhou2.jpg"
			}, {
				"url": "/standard_static/test_resource_img/hangzhou3.jpg"
			}],
			"is_enable_model": "启用规格",
			"model": {
				"models": {
					"黑色 S": {
						"price": 20.00,
						"stock_type": "有限",
						"stocks": 3
					},
					"白色 S": {
						"price": 10.00,
						"stock_type": "无限"
					}
				}
			}
			},{
				"name": "买赠和会员价2",
				"promotion_title": "全部买赠和会员价",
				"detail": "买赠和会员价2的详情",
				"is_member_product": "on",
				"status": "在售",
				"swipe_images": [{
					"url": "/standard_static/test_resource_img/hangzhou2.jpg"
					}],
				"model": {
					"models": {
						"standard": {
							"price": 100.00,
							"stock_type": "无限"
						}
					}
				}
			},{
				"name": "赠品1",
				"status": "在售",
				"price": 100.00,
				"stock_type": "无限"
		}]
		"""
	When jobs创建买赠活动
		"""
		[{
			"name": "铜牌买赠和会员价1",
			"promotion_title":"铜牌买赠啦",
			"start_date": "今天",
			"end_date": "1天后",
			"member_grade": "铜牌会员",
			"product_name": "买赠和会员价1",
			"premium_products":
			[{
				"name": "赠品1",
				"count": 1
			}],
			"count": 2,
			"is_enable_cycle_mode": true
		},{
			"name": "全部买赠和会员价2",
			"promotion_title":"全部买赠啦",
			"start_date": "今天",
			"end_date": "1天后",
			"member_grade": "全部会员",
			"product_name": "买赠和会员价2",
			"premium_products":
			[{
				"name": "赠品1",
				"count": 1
			}],
			"count": 2,
			"is_enable_cycle_mode": true
		}]
		"""
	#普通会员浏览'买赠和会员价1',显示会员价
		When tom访问jobs的webapp
		And tom浏览jobs的webapp的'买赠和会员价1'商品页
		Then webapp页面标题为'买赠和会员价1'
		And tom获得webapp商品
			"""
			{
				"name": "买赠和会员价1",
				"promotion_title": "铜牌买赠和会员价",
				"detail": "买赠和会员价1的详情",
				"swipe_images": [{
					"url": "/standard_static/test_resource_img/hangzhou1.jpg"
				}, {
					"url": "/standard_static/test_resource_img/hangzhou2.jpg"
				}, {
					"url": "/standard_static/test_resource_img/hangzhou3.jpg"
				}],
				"model": {
					"models": {
						"黑色 S": {
							"price": 20.00,
							"member_price": 18.00,
							"stocks": 3
						},
						"白色 S": {
							"price": 10.00,
							"member_price": 9.00
						}
					}
				}
			}
			"""

	#铜牌会员浏览'买赠和会员价1',显示买赠价,不显示会员价
		When bill访问jobs的webapp
		And bill浏览jobs的webapp的'买赠和会员价1'商品页
		Then webapp页面标题为'买赠和会员价1'
		And bill获得webapp商品
			"""
			{
				"name": "买赠和会员价1",
				"promotion_title": "铜牌买赠啦",
				"detail": "买赠和会员价1的详情",
				"swipe_images": [{
					"url": "/standard_static/test_resource_img/hangzhou1.jpg"
				}, {
					"url": "/standard_static/test_resource_img/hangzhou2.jpg"
				}, {
					"url": "/standard_static/test_resource_img/hangzhou3.jpg"
				}],
				"model": {
					"models": {
						"黑色 S": {
							"price": 20.00,
							"stocks": 3
						},
						"白色 S": {
							"price": 10.00
						}
					}
				}
			}
			"""

	#普通会员浏览'买赠和会员价2',显示买赠价,不显示会员价
		When tom访问jobs的webapp
		And tom浏览jobs的webapp的'买赠和会员价2'商品页
		Then webapp页面标题为'买赠和会员价2'
		And tom获得webapp商品
			"""
			{
				"name": "买赠和会员价2",
				"promotion_title": "全部买赠啦",
				"detail": "买赠和会员价2的详情",
				"status": "在售",
				"swipe_images": [{
					"url": "/standard_static/test_resource_img/hangzhou2.jpg"
					}],
				"model": {
					"models": {
						"standard": {
							"price": 100.00
						}
					}
				}
			}
			"""

	#铜牌会员浏览'买赠和会员价2',显示买赠价,不显示会员价
		When bill访问jobs的webapp
		And bill浏览jobs的webapp的'买赠和会员价2'商品页
		Then webapp页面标题为'买赠和会员价2'
		And bill获得webapp商品
			"""
			{
				"name": "买赠和会员价2",
				"promotion_title": "全部买赠啦",
				"detail": "买赠和会员价2的详情",
				"status": "在售",
				"swipe_images": [{
					"url": "/standard_static/test_resource_img/hangzhou2.jpg"
					}],
				"model": {
					"models": {
						"standard": {
							"price": 100.00
						}
					}
				}
			}
			"""


#补充：雪静 2016.1.13
	#针对积分活动商品详情页积分抵扣的详情
@product @ui @ProductList
Scenario:5 参与积分活动的商品详情页

	Given jobs登录系统
	Given jobs设定会员积分策略
		"""
		{
			"integral_each_yuan": 3
		}
		"""
	When jobs创建积分应用活动
		"""
		[{
			"name": "商品1积分应用",
			"start_date": "今天",
			"end_date": "1天后",
			"product_name": "商品1",
			"is_permanant_active": false,
			"rules": [{
				"member_grade": "全部",
				"discount": 50,
				"discount_money": "5.0~10.0"
			}]
		}]
		"""
	When bill访问jobs的webapp
	When bill获得jobs的100会员积分
	Then bill在jobs的webapp中拥有100会员积分
	And bill浏览jobs的webapp的'商品1'商品页
	#享受会员价的会员能获取商品原价和会员价
	#设置了起购数量3，商品详情页提示“至少购买3件”
	#设置了积分活动，商品详情页会显示
	#会员积分大于商品抵扣的积分
	Then webapp页面标题为'商品1'
	And bill获得webapp商品
		"""
		{
			"name": "商品1",
			"promotion_title": "促销的东坡肘子",
			"detail": "东坡肘子的详情",
			"swipe_images": [{
				"url": "/standard_static/test_resource_img/hangzhou1.jpg"
			}, {
				"url": "/standard_static/test_resource_img/hangzhou2.jpg"
			}, {
				"url": "/standard_static/test_resource_img/hangzhou3.jpg"
			}],
			"model": {
				"models": {
					"黑色 S": {
						"price": 20.00,
						"member_price": 18.00,
						"stocks": 3,
						"count": 3,
						"提示信息": "库存不足",
						"提示信息": "至少购买3件",
						"提示信息": "最多可使用27积分，抵扣9.00元"
					},
					"白色 S": {
						"price": 10.00,
						"member_price": 9.00,
						"count": 3,
						"提示信息": "至少购买3件",
						"提示信息": "最多可使用14积分，抵扣4.50元"
					}
				}
			}
		}
		"""
	When bill访问jobs的webapp
	When bill获得jobs的20会员积分
	Then bill在jobs的webapp中拥有20会员积分
	And bill浏览jobs的webapp的'商品1'商品页
	#享受会员价的会员能获取商品原价和会员价
	#设置了起购数量3，商品详情页提示“至少购买3件”
	#设置了积分活动，商品详情页会显示
	#会员积分小于商品抵扣的积分
	Then webapp页面标题为'商品1'
	And bill获得webapp商品
		"""
		{
			"name": "商品1",
			"promotion_title": "促销的东坡肘子",
			"detail": "东坡肘子的详情",
			"swipe_images": [{
				"url": "/standard_static/test_resource_img/hangzhou1.jpg"
			}, {
				"url": "/standard_static/test_resource_img/hangzhou2.jpg"
			}, {
				"url": "/standard_static/test_resource_img/hangzhou3.jpg"
			}],
			"model": {
				"models": {
					"黑色 S": {
						"price": 20.00,
						"member_price": 18.00,
						"stocks": 3,
						"count": 3,
						"提示信息": "库存不足",
						"提示信息": "至少购买3件",
						"提示信息": "最多可使用20积分，抵扣6.67元"
					},
					"白色 S": {
						"price": 10.00,
						"member_price": 9.00,
						"count": 3,
						"提示信息": "至少购买3件",
						"提示信息": "最多可使用14积分，抵扣4.50元"
					}
				}
			}
		}
		"""



#补充：田丰敏 2016.09.01
#2016-09-01 新增浏览有禁售/仅售限制的商品详情页
#	1、仅售或禁售地区配置数量等于或大于5个时：

#		（1）商品配置仅售限制时，商品详情页面可以看到提示信息：此商品只在部分地区销售；
#		（2）商品配置禁售限制时，商品详情页面可以看到提示信息：此商品部分地区不派送
#		（3）可点击提示信息后方的“查看详情”弹出查看地区的弹窗，浏览仅售或禁售地区，展示省和市，其中如果省全选则的话只展示省

#	2、仅售或禁售地区配置数量小于5个时：
#		（1）商品配置仅售或禁售限制时，商品详情页面直接粗体字显示地区，不显示“查看详情”
#		（2）当一个省都选择的时候，显示一级的省，不显示市，当选择了部分二级的市时，显示第二级的市


Scenario:6 有禁售/仅售限制的商品详情页
	Given jobs登录系统
	When jobs添加限定区域配置
		"""
		{
			"name": "禁售商品地区",
			"limit_area": [{
				"area": "直辖市",
				"province": ["上海市"]
			},{
				"area": "华北-东北",
				"province": "河北省",
				"city": ["石家庄市","唐山市","沧州市"]
			},{
				"area": "其他",
				"province": ["香港","澳门"]
			}]
		}
		"""
	When jobs添加限定区域配置
		"""
		{
			"name": "仅售商品地区",
			"limit_area": [{
				"area": "直辖市",
				"province": ["北京市","天津市"]
			}]
		}
		"""
	When jobs添加限定区域配置
		"""
		{
			"name": "仅售商品多地区",
			"limit_area": [{
				"area": "直辖市",
				"province": ["北京市","天津市"]
			},{
				"area": "华北-东北",
				"province": "河北省",
				"city": ["石家庄市","唐山市","沧州市"]
			},{
				"area": "华北-东北",
				"province": "山西省",
				"city": ["太原市","大同市","阳泉市","长治市","晋城市","朔州市","晋中市","运城市","忻州市","临汾市","吕梁市"]
			},{
				"area": "华东地区",
				"province": "江苏省",
				"city": ["苏州市"]
			},{
				"area": "西北-西南",
				"province": "陕西省",
				"city": ["西安市"]
			},{
				"area": "其他",
				"province": ["香港","澳门"]
			}]
		}
		"""
	And jobs已添加商品
		"""
		[{
			"name": "禁售地区商品",
			"category": "",
			"detail": "商品的详情",
			"status": "在售",
			"limit_zone_type": {
				"禁售地区": {
					"limit_zone": "禁售商品地区"
				}
			},
			"model": {
					"models": {
						"standard": {
							"price": 12.00,
							"stock_type": "有限",
							"stocks": 3
						}
					}
				}
		}, {
			"name": "仅售商品多地区商品",
			"category": "",
			"detail": "商品的详情",
			"status": "在售",
			"limit_zone_type": {
				"仅售地区": {
					"limit_zone": "仅售商品多地区"
				}
			},
			"model": {
					"models": {
						"standard": {
							"price": 12.00,
							"stock_type": "有限",
							"stocks": 3
						}
					}
				}
		}, {
			"name": "仅售商品地区商品",
			"category": "",
			"detail": "商品的详情",
			"status": "在售",
			"limit_zone_type": {
				"仅售地区": {
					"limit_zone": "仅售商品地区"
				}
			},
			"model": {
					"models": {
						"standard": {
							"price": 12.00,
							"stock_type": "有限",
							"stocks": 3
						}
					}
				}
		}]
		"""
	When bill访问jobs的webapp
	When bill浏览jobs的webapp的'禁售地区商品'商品页
	Then webapp页面标题为'禁售地区商品'
	And bill获得webapp商品
		"""
		{
			"name": "禁售地区商品",
			"category": "",
			"detail": "商品的详情",
			"status": "在售",
			"model": {
				"models": {
					"standard": {
						"price": 12.00,
						"stocks": 3,
						"提示信息": "此商品部分地区不派送"
					}
				}
			}
		}
		"""
	And bill获得商品'禁售地区商品'限定区域
		"""
		{
			"limit_area": [{
				"province": ["上海市"]
			},{
				"province": "河北省",
				"city": ["石家庄市","唐山市","沧州市"]
			},{
				"province": ["香港","澳门"]
			}]
		}
		"""
	When bill访问jobs的webapp
	When bill浏览jobs的webapp的'仅售商品多地区商品'商品页
	Then webapp页面标题为'仅售商品多地区商品'
	And bill获得webapp商品
		"""
		{
			"name": "仅售商品多地区商品",
			"category": "",
			"detail": "商品的详情",
			"status": "在售",
			"model": {
				"models": {
					"standard": {
						"price": 12.00,
						"stocks": 3,
						"提示信息": "此商品只在部分地区销售"
					}
				}
			}
		}
		"""
	And bill获得商品'仅售商品多地区商品'限定区域
		"""
		{
			"limit_area": [{
				"province": ["北京市","天津市"]
			},{
				"province": "河北省",
				"city": ["石家庄市","唐山市","沧州市"]
			},{
				"province": "山西省"
			},{
				"province": "江苏省",
				"city": ["苏州市"]
			},{
				"province": "陕西省",
				"city": ["西安市"]
			},{
				"area": "其他",
				"province": ["香港","澳门"]
			}]
		}
		"""
	When bill访问jobs的webapp
	When bill浏览jobs的webapp的'仅售商品地区商品'商品页
	Then webapp页面标题为'仅售商品地区商品'
	And bill获得webapp商品
		"""
		{
			"name": "仅售商品地区商品",
			"category": "",
			"detail": "商品的详情",
			"status": "在售",
			"model": {
				"models": {
					"standard": {
						"price": 12.00,
						"stocks": 3
					}
				}
			}
		}
		"""
	And bill获得商品'仅售商品地区商品'限定区域
		"""
		{
			"limit_area": [{
				"province": ["北京市","天津市"]
			}]
		}
		"""

#后台修改禁售地区限定区域配置

	Given jobs登录系统
	When jobs修改'禁售地区'限定区域配置
		"""
		{
			"name": "禁售商品地区",
			"limit_area": [{
				"area": "直辖市",
				"province": ["上海市"]
			},{
				"area": "其他",
				"province": ["香港","澳门"]
			}]
		}
		"""

	When bill访问jobs的webapp
	When bill浏览jobs的webapp的'禁售地区商品'商品页
	Then webapp页面标题为'禁售地区商品'
	And bill获得webapp商品
		"""
		{
			"name": "禁售地区商品",
			"category": "",
			"detail": "商品的详情",
			"status": "在售",
			"model": {
				"models": {
					"standard": {
						"price": 12.00,
						"stocks": 3
					}
				}
			}
		}
		"""
	And bill获得商品'禁售地区商品'限定区域
		"""
		{
			"limit_area": [{
				"province": ["上海市"]
			},{
				"province": ["香港","澳门"]
			}]
		}
		"""


#后台删除仅售地区限定区域配置

	Given jobs登录系统
	When jobs删除'仅售商品地区'限定区域配置

	When bill访问jobs的webapp
	When bill浏览jobs的webapp的'仅售商品地区商品'商品页
	Then webapp页面标题为'仅售商品地区商品'
	And bill获得webapp商品
		"""
		{
			"name": "仅售商品地区商品",
			"category": "",
			"detail": "商品的详情",
			"status": "在售",
			"model": {
				"models": {
					"standard": {
						"price": 12.00,
						"stocks": 3
					}
				}
			}
		}
		"""

