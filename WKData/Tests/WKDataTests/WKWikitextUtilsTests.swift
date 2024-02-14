import XCTest
@testable import WKData

final class WKWikitextUtilsTests: XCTestCase {
    
    override func setUp() async throws {
        
    }
    
    func testEnglishInsertImageWikitextIntoArticleWikitext() throws {
        
        let imageWikitext = "[[File: Cat.jpg | thumb | 220x124px | right | alt=Cat alt text | Cat caption text]]"
        
        let initialArticleWikitext = """
        {{Short description|Small domesticated carnivorous mammal}}
        {{About|the species commonly kept as a pet|the cat family|Felidae|other uses|Cat (disambiguation)|and|Cats (disambiguation)}}
        {{Good article}}
        {{pp-semi-indef|small=yes}}
        {{pp-move|small=yes}}
        {{Use American English|date=January 2020}}
        {{Use dmy dates|date=October 2022}}<!-- Per MOS:ENGVAR and MOS:DATEVAR, articles should conform to one overall spelling of English and date format, typically the ones with which it was created when the topic has no strong national ties. This article was created with American English, using international date format (DD Month YYYY), and should continue to be written that way. If there is a compelling reason to change it propose a change on the talk page. -->
        {{Speciesbox
         |name=Cat
        <!-- There has been extensive discussion about the choice of image in this infobox. Before replacing this image with something else, consider if it actually improves on the ENCYCLOPEDIC CRITERIA which led to this choice. See [[Talk:Cat]] and [[Talk:Cat/Lead photo]] and if in doubt, DISCUSS IT FIRST! -->
         |fossil_range=9,500 years ago – present
         |image={{Multiple image
          |perrow=2/2/2
          |total_width=275
          |image1=Cat August 2010-4.jpg
          |image2=Gustav chocolate.jpg
          |image3=Orange tabby cat sitting on fallen leaves-Hisashi-01A.jpg
          |image4=Siam lilacpoint.jpg
          |image5=Felis catus-cat on snow.jpg
          |image6=Sheba1.JPG
          |border=infobox
          |footer=Various types of cats
        }}
         |status=DOM
         |genus=Felis
         |species=catus<ref name="Linnaeus1758" />
         |authority=[[Carl Linnaeus|Linnaeus]], [[10th edition of Systema Naturae|1758]]<ref name="MSW3fc" />
         |synonyms=*''Catus domesticus'' {{small|[[Johann Christian Polycarp Erxleben|Erxleben]], 1777}}<ref name="Erxleben">{{Cite book |last=Erxleben |first=J. C. P. |date=1777 |title=Systema regni animalis per classes, ordines, genera, species, varietates cvm synonymia et historia animalivm. Classis I. Mammalia |location=Lipsiae |publisher=Weygandt |pages=520–521 |chapter=Felis Catus domesticus |chapter-url= https://archive.org/details/iochristpolycerx00erxl/page/520}}</ref>
        * ''F. angorensis'' {{small|[[Karl Christian Gmelin|Gmelin]], 1788}}
        * ''F. vulgaris'' {{small|Fischer, 1829}}
        }}

        The '''cat''' ('''''Felis catus'''''), commonly referred to as the '''domestic cat''' or '''house cat''', is the only [[Domestication of animals|domesticated]] species in the family [[Felidae]]. Recent advances in [[archaeology]] and [[genetics]] have shown that the [[domestication of the cat]] occurred in the [[Near East]] around 7500 [[Before Christ|BC]]. It is commonly kept as a house pet and [[farm cat]], but also ranges freely as a [[feral cat]] avoiding human contact. It is valued by humans for companionship and its ability to kill [[vermin]]. Because of its retractable [[claw]]s it is adapted to killing small prey like [[mice]] and [[rat]]s. It has a strong flexible body, quick [[reflexes]], sharp teeth, and its [[night vision]] and [[sense of smell]] are well developed. It is a [[social species]], but a solitary hunter and a [[crepuscular]] [[predator]]. [[Cat communication]] includes vocalizations like [[meow]]ing, [[purr]]ing, trilling, hissing, [[growling]], and grunting as well as [[cat body language]]. It can hear sounds too faint or too high in [[frequency]] for human ears, such as those made by small mammals. It also secretes and perceives [[pheromones]].
        """
        
        let insertedArticleWikitext = try WKWikitextUtils.insertImageWikitextIntoArticleWikitextAfterTemplates(imageWikitext: imageWikitext, into: initialArticleWikitext)
        let expectedInsertedArticleWikitext = """
        {{Short description|Small domesticated carnivorous mammal}}
        {{About|the species commonly kept as a pet|the cat family|Felidae|other uses|Cat (disambiguation)|and|Cats (disambiguation)}}
        {{Good article}}
        {{pp-semi-indef|small=yes}}
        {{pp-move|small=yes}}
        {{Use American English|date=January 2020}}
        {{Use dmy dates|date=October 2022}}<!-- Per MOS:ENGVAR and MOS:DATEVAR, articles should conform to one overall spelling of English and date format, typically the ones with which it was created when the topic has no strong national ties. This article was created with American English, using international date format (DD Month YYYY), and should continue to be written that way. If there is a compelling reason to change it propose a change on the talk page. -->
        {{Speciesbox
         |name=Cat
        <!-- There has been extensive discussion about the choice of image in this infobox. Before replacing this image with something else, consider if it actually improves on the ENCYCLOPEDIC CRITERIA which led to this choice. See [[Talk:Cat]] and [[Talk:Cat/Lead photo]] and if in doubt, DISCUSS IT FIRST! -->
         |fossil_range=9,500 years ago – present
         |image={{Multiple image
          |perrow=2/2/2
          |total_width=275
          |image1=Cat August 2010-4.jpg
          |image2=Gustav chocolate.jpg
          |image3=Orange tabby cat sitting on fallen leaves-Hisashi-01A.jpg
          |image4=Siam lilacpoint.jpg
          |image5=Felis catus-cat on snow.jpg
          |image6=Sheba1.JPG
          |border=infobox
          |footer=Various types of cats
        }}
         |status=DOM
         |genus=Felis
         |species=catus<ref name="Linnaeus1758" />
         |authority=[[Carl Linnaeus|Linnaeus]], [[10th edition of Systema Naturae|1758]]<ref name="MSW3fc" />
         |synonyms=*''Catus domesticus'' {{small|[[Johann Christian Polycarp Erxleben|Erxleben]], 1777}}<ref name="Erxleben">{{Cite book |last=Erxleben |first=J. C. P. |date=1777 |title=Systema regni animalis per classes, ordines, genera, species, varietates cvm synonymia et historia animalivm. Classis I. Mammalia |location=Lipsiae |publisher=Weygandt |pages=520–521 |chapter=Felis Catus domesticus |chapter-url= https://archive.org/details/iochristpolycerx00erxl/page/520}}</ref>
        * ''F. angorensis'' {{small|[[Karl Christian Gmelin|Gmelin]], 1788}}
        * ''F. vulgaris'' {{small|Fischer, 1829}}
        }}
        
        [[File: Cat.jpg | thumb | 220x124px | right | alt=Cat alt text | Cat caption text]]
        The '''cat''' ('''''Felis catus'''''), commonly referred to as the '''domestic cat''' or '''house cat''', is the only [[Domestication of animals|domesticated]] species in the family [[Felidae]]. Recent advances in [[archaeology]] and [[genetics]] have shown that the [[domestication of the cat]] occurred in the [[Near East]] around 7500 [[Before Christ|BC]]. It is commonly kept as a house pet and [[farm cat]], but also ranges freely as a [[feral cat]] avoiding human contact. It is valued by humans for companionship and its ability to kill [[vermin]]. Because of its retractable [[claw]]s it is adapted to killing small prey like [[mice]] and [[rat]]s. It has a strong flexible body, quick [[reflexes]], sharp teeth, and its [[night vision]] and [[sense of smell]] are well developed. It is a [[social species]], but a solitary hunter and a [[crepuscular]] [[predator]]. [[Cat communication]] includes vocalizations like [[meow]]ing, [[purr]]ing, trilling, hissing, [[growling]], and grunting as well as [[cat body language]]. It can hear sounds too faint or too high in [[frequency]] for human ears, such as those made by small mammals. It also secretes and perceives [[pheromones]].
        """
        XCTAssertEqual(insertedArticleWikitext, expectedInsertedArticleWikitext)
    }
    
    func testArabicInsertImageWikitextIntoArticleWikitext() throws {
        
        let imageWikitext = "[[File: Cat.jpg | thumb | 220x124px | right | alt=Cat alt text | Cat caption text]]"
        
        let initialArticleWikitext = """
        {{عن|3=الأرض (توضيح)}}
        {{عن|كوكب الأرض|فيلم الأرض|الأرض (فيلم)}}
        {{معلومات كوكب
        | الاسم = الأرض
        |الرمز = &nbsp;[[ملف:Earth symbol (black).svg|24px|🜨]]
        | الصورة = The Blue Marble (remastered).jpg
        | التعليق = "[[الرخام الأزرق|الكتلة الزرقاء]]"، إحدى صور الأرض التي التقطها مسبار [[أبولو 17]]
        | مرجع_الاكتشاف =
        | المكتشف =
        | موقع_الاكتشاف =
        | الاكتشاف =
        | وسيلة_الاكتشاف =
        | تسمية_الكوكب_الصغير =
        | فئة_الكوكب_الصغير =
        | أسماء_بديلة = الكوكب المائي - العالم
        | مرجع_المدار =
        | الدهر = J2000.0
        | القبا =
        | الشكل = [[كرواني مفلطح|كروي مفلطح]]
        | الأوج = 152,098,232&nbsp;كم<br/> 1.01671388&nbsp;[[وحدة فلكية]]
        | الحضيض = 147,098,290&nbsp;كم<br/> 0.98329134&nbsp;وحدة فلكية
        | الكمّ =
        | البعد =
        | نصف المحور الرئيسي = 149,598,261&nbsp;كم<br/> 1.00000261&nbsp;وحدة فلكية
        | الشذوذ المداري = 0.01671123
        | فترة الدوران = 365.256363004&nbsp;أيام<br/>1.000017421&nbsp;[[سنة يوليوسية]]
        | الفترة_الإقترانية =
        | متوسط_السرعة_المدارية = 29.78&nbsp;كم/ث<br/>107,200&nbsp;كم/س

        | زاوية_وسط_الشذوذ = 357.51716°
        | الميل المداري = 7.155° بالنسبة [[دائرة الكسوف|لخط الاستواء]]<br/>1.57869° بالنسبة إلى [[مستو (رياضيات)|مستو ثابت]]
        | قطر_زاو =
        | زاوية_نقطة_الاعتدال = 348.73936°
        | خط_طول_الكمّ =
        | زمن_الكمّ =
        | زاوية_الحضيض = 114.20783°
        | نصف-المطال =
        | تابع_إلى =
        | الأقمار = 1&nbsp;([[القمر|القمر الطبيعي الوَحيد للكرة الأرضيَّة]])<br/>
        فضلًا عن 2,787 [[قمر اصطناعي|قمر صناعي أو ساتل فَضائي]] <small>(2020)</small><ref name=ucs>{{استشهاد ويب |مسار=https://www.ucsusa.org/resources/satellite-database |عنوان=UCS Satellite Database |عمل=Nuclear Weapons & Global Security |ناشر=[[Union of Concerned Scientists]] |تاريخ=1 August 2020 |تاريخ الوصول=27 September 2018| مسار أرشيف = https://web.archive.org/web/20190824003501/https://www.ucsusa.org/nuclear-weapons/space-weapons/satellite-database | تاريخ أرشيف = 24 أغسطس 2019 }}</ref>
        | الأبعاد =
        | التسطيح = 0.0033528
        | نصف_القطر_الإستوائي = 6,378.1&nbsp;كم
        | نصف_القطر_القطبي = 6,356.8&nbsp;كم
        | متوسط_نصف_القطر = 6,371.0&nbsp;كم
        | المحيط = 40,075.16&nbsp;كم&nbsp;(عند [[خط الاستواء]])<br/>40,008.00&nbsp;كم&nbsp;(على [[خط طول|طول دائرة الطول]])
        | مساحة_السطح = 510,072,000&nbsp;كم<sup>2</sup><br/>{{بدون لف|148,940,000 كم<sup>2</sup> من اليابسة  (29.2%)}}<br/>
        {{بدون لف|361,132,000 كم<sup>2</sup> من الماء (70.8%)}}
        | الحجم = 1.08321{{*10^|12}}&nbsp;كم<sup>3</sup>
        | الكتلة = 5.9736{{*10^|24}}&nbsp;كغ
        | الكثافة = 5.515&nbsp;غرام/سم<sup>3</sup>
        | جاذبية_السطح = 9.780327 م/ث<sup>2</sup><br/>0.99732&nbsp;''غ''
        | سرعة_الإفلات = 11.186&nbsp;كم/ث
        | اليوم_الفلكي = 0.99726968&nbsp;أيام<br/>23{{smallsup|س}}&nbsp;56{{smallsup|د}}&nbsp;4.100{{smallsup|ث}}
        | سرعة_الدوران = 1674.4 كم/س
        | الميل المحوري = 23°26'21".4119
        | المطلع_المستقيم_القطبي_الشمالي =
        | الميلان =
        | خط_العرض_الكسوفي_القطبي =
        | خط_الطول_الكسوفي_القطبي =
        | البياض = 0.367
        | درجة_حرارة =
        | وحدة_الحرارة1 = [[كلفن]]
        | الدرجة_الدنيا_1 = 184&nbsp;ك
        | الدرجة_المتوسطة_1 = 287.2&nbsp;ك
        | الدرجة_القصوى_1 = 331&nbsp;ك
        | وحدة_الحرارة2 = [[درجة حرارة مئوية|مئوية]]
        | الدرجة_الدنيا_2 = -89.2&nbsp;°م
        | الدرجة_المتوسطة_2 = 14&nbsp;°م
        | الدرجة_القصوى_2 = 57.8&nbsp;°م
        | النمط_الطيفي =
        | القدر =
        | atmosphere = yes
        | atmosphere_ref =
        | الضغط_السطحي = 101.325&nbsp;[[باسكال (وحدة)|كيلوباسكال]] ([[مستوى سطح البحر|مستوى البحر]])
        | مقياس_الارتفاع =
        | عناصر_الغلاف_الجوي = {{قائمة مخفية
        |title       =
        |frame_style =
        |title_style =
        |list_style   = text-align:right;display:none;
        |78.08%&nbsp;[[نيتروجين]] - N<sub>2</sub>
        |20.95%&nbsp;[[أكسجين]] -O<sub>2</sub>
        |0.93%&nbsp;[[آرغون]]
        |0.038%&nbsp;[[ثنائي أكسيد الكربون|ثاني أكسيد الكربون]]
        |حوالي 1% من [[بخار الماء]] (تختلف النسبة باختلاف [[مناخ|المناخ]])
        }}
        }}
        '''الأَرْض'''<ref>{{استشهاد بويكي بيانات|Q113297966|ص=1368}}</ref> ([[رمز فلكي|رمزها]]: [[ملف:Earth symbol (fixed width).svg|16px|🜨]]) هي ثالث كواكب [[المجموعة الشمسية]] بعدًا عن [[الشمس]] بعد [[عطارد]] و[[الزهرة]]، وتُعتبر من أكبر [[كوكب|الكواكب]] [[كوكب أرضي|الأرضية]] وخامس أكبر الكواكب في [[المجموعة الشمسية|النظام الشمسي]]،<ref>{{استشهاد ويب |عنوان=كواكب المجموعة الشمسية بالترتيب حسب الحجم |تاريخ الوصول=25 مارس 2020 |ناشر=موقع سطور|تاريخ أرشيف=2020-03-25}} {{مراجعة مرجع|تاريخ=أغسطس 2020}}</ref> وذلك من حيث قطرها وكتلتها وكثافتها، ويُطلق على هذا الكوكب أيضًا اسم ''[[العالم]]''.
        [[ملف:EpicEarth-Globespin(2016May29).gif|تصغير|22 صورة للأرض تم التقاطها من الفضاء عبر القمر الصناعي ديسكفر.]]
        تعتبر الأرض مسكنًا لملايين [[نوع (تصنيف)|الأنواع]] <ref>{{استشهاد بدورية محكمة
        | الأخير = May | الأول = Robert M.
        | عنوان=How many species are there on earth?
        | صحيفة=Science | سنة=1988 | المجلد=241
        | العدد=4872 | صفحات=1441–1449
        | مسار=https://adsabs.harvard.edu/abs/1988Sci...241.1441M
        | تاريخ الوصول=2007-08-14
        | doi=10.1126/science.241.4872.1441
        | pmid=17790039| مسار أرشيف = https://web.archive.org/web/20190321122146/http://adsabs.harvard.edu/abs/1988Sci...241.1441M | تاريخ أرشيف = 21 مارس 2019 }}</ref> من الكائنات الحية، بما فيها [[إنسان|الإنسان]]؛ وهي المكان الوحيد المعروف بوجود [[حياة]] عليه في [[الكون]]. تكونت الأرض منذ [[عمر كوكب الأرض|حوالي 4.54 مليار]] [[سنة]]،<ref name="age_earth1">{{استشهاد بكتاب
        | الأول=G.B. | الأخير=Dalrymple | سنة=1991
        | عنوان=The Age of the Earth | مسار=https://archive.org/details/ageofearth00unse | ناشر=Stanford University Press | مكان=California
        |ردمك=0-8047-1569-6
        }}</ref><ref name="age_earth2">{{استشهاد ويب
        | الأخير=Newman | الأول=William L. | تاريخ=2007-07-09
        | مسار=https://pubs.usgs.gov/gip/geotime/age.html
        | عنوان=Age of the Earth
        | ناشر=Publications Services, USGS
        | تاريخ الوصول=2007-09-20
        | مسار أرشيف = https://web.archive.org/web/20190531135529/https://pubs.usgs.gov/gip/geotime/age.html | تاريخ أرشيف = 31 مايو 2019 }}</ref><ref name="age_earth3">{{استشهاد بدورية محكمة
        | الأخير=Dalrymple | الأول=G. Brent | عنوان=The age of the Earth in the twentieth century: a problem (mostly) solved
        | صحيفة=Geological Society, London, Special Publications
        | سنة=2001 | المجلد=190 | صفحات=205–221 | مسار=https://sp.lyellcollection.org/content/190/1/205.abstract
        | تاريخ الوصول=2007-09-20
        | doi = 10.1144/GSL.SP.2001.190.01.14
        | مسار أرشيف = https://web.archive.org/web/20100205160041/http://sp.lyellcollection.org/cgi/content/abstract/190/1/205 | تاريخ أرشيف = 5 فبراير 2010 }}</ref><ref name="age_earth4">{{استشهاد ويب
        | الأخير=Stassen | الأول=Chris | تاريخ=2005-09-10 | مسار=https://www.toarchive.org/faqs/faq-age-of-earth.html
        | عنوان=The Age of the Earth | ناشر=[[TalkOrigins Archive]] | تاريخ الوصول=2008-12-30
        | مسار أرشيف = https://web.archive.org/web/20090218132039/http://toarchive.org:80/faqs/faq-age-of-earth.html | تاريخ أرشيف = 18 فبراير 2009 }}</ref> وقد ظهرت الحياة على سطحها بين حوالي 3,5 إلى 3,8 مليارات سنة مضت.<ref>https://www.ibelieveinsci.com/%D8%A7%D9%84%D8%AA%D8%B7%D9%88%D8%B1-%D9%88-%D8%A3%D8%B5%D9%84-%D8%A7%D9%84%D8%AD%D9%8A%D8%A7%D8%A9/ {{Webarchive|url=https://web.archive.org/web/20230307142018/https://www.ibelieveinsci.com/%D8%A7%D9%84%D8%AA%D8%B7%D9%88%D8%B1-%D9%88-%D8%A3%D8%B5%D9%84-%D8%A7%D9%84%D8%AD%D9%8A%D8%A7%D8%A9/|date=2023-03-07}}</ref> ومنذ ذلك الحين أدى [[محيط حيوي|الغلاف الحيوي]] للأرض إلى تغير [[غلاف الأرض الجوي|الغلاف الجوي]] والظروف غير الحيوية الموجودة على الكوكب، مما سمح بتكاثر الكائنات التي تعيش فقط في ظل وجود [[أكسجين|الأكسجين]] وتكوّن [[طبقة الأوزون]]، التي تعمل مع [[حقل مغناطيسي|المجال المغناطيسي]] للأرض على حجب [[أشعة الشمس|الإشعاعات]] الضارة، مما يسمح بوجود الحياة على سطح الأرض. تحجب طبقة الأوزون [[الأشعة فوق البنفسجية]]، ويعمل [[حقل مغناطيسي|المجال المغناطيسي]] للأرض على إزاحة وإبعاد [[جسيم أولي|الجسيمات الأولية]] المشحونة القادمة من [[الشمس]] بسرعات عظيمة ويبعدها في الفضاء الخارجي بعيدا عن الأرض، فلا تتسبب في الإضرار بالكائنات الحية.<ref>{{استشهاد بكتاب
        | الأول=Roy M. | الأخير=Harrison
        | المؤلفون=Hester, Ronald E. | سنة=2002
        | عنوان=Causes and Environmental Implications of Increased UV-B Radiation
        | مسار=https://archive.org/details/causesenvironmen0000unse | ناشر=Royal Society of Chemistry
        |ردمك=0854042652| مسار أرشيف = https://web.archive.org/web/20220712145137/https://archive.org/details/causesenvironmen0000unse | تاريخ أرشيف = 12 يوليو 2022 }}</ref>
        """
        
        let insertedArticleWikitext = try WKWikitextUtils.insertImageWikitextIntoArticleWikitextAfterTemplates(imageWikitext: imageWikitext, into: initialArticleWikitext)
        let expectedInsertedArticleWikitext = """
        {{عن|3=الأرض (توضيح)}}
        {{عن|كوكب الأرض|فيلم الأرض|الأرض (فيلم)}}
        {{معلومات كوكب
        | الاسم = الأرض
        |الرمز = &nbsp;[[ملف:Earth symbol (black).svg|24px|🜨]]
        | الصورة = The Blue Marble (remastered).jpg
        | التعليق = "[[الرخام الأزرق|الكتلة الزرقاء]]"، إحدى صور الأرض التي التقطها مسبار [[أبولو 17]]
        | مرجع_الاكتشاف =
        | المكتشف =
        | موقع_الاكتشاف =
        | الاكتشاف =
        | وسيلة_الاكتشاف =
        | تسمية_الكوكب_الصغير =
        | فئة_الكوكب_الصغير =
        | أسماء_بديلة = الكوكب المائي - العالم
        | مرجع_المدار =
        | الدهر = J2000.0
        | القبا =
        | الشكل = [[كرواني مفلطح|كروي مفلطح]]
        | الأوج = 152,098,232&nbsp;كم<br/> 1.01671388&nbsp;[[وحدة فلكية]]
        | الحضيض = 147,098,290&nbsp;كم<br/> 0.98329134&nbsp;وحدة فلكية
        | الكمّ =
        | البعد =
        | نصف المحور الرئيسي = 149,598,261&nbsp;كم<br/> 1.00000261&nbsp;وحدة فلكية
        | الشذوذ المداري = 0.01671123
        | فترة الدوران = 365.256363004&nbsp;أيام<br/>1.000017421&nbsp;[[سنة يوليوسية]]
        | الفترة_الإقترانية =
        | متوسط_السرعة_المدارية = 29.78&nbsp;كم/ث<br/>107,200&nbsp;كم/س

        | زاوية_وسط_الشذوذ = 357.51716°
        | الميل المداري = 7.155° بالنسبة [[دائرة الكسوف|لخط الاستواء]]<br/>1.57869° بالنسبة إلى [[مستو (رياضيات)|مستو ثابت]]
        | قطر_زاو =
        | زاوية_نقطة_الاعتدال = 348.73936°
        | خط_طول_الكمّ =
        | زمن_الكمّ =
        | زاوية_الحضيض = 114.20783°
        | نصف-المطال =
        | تابع_إلى =
        | الأقمار = 1&nbsp;([[القمر|القمر الطبيعي الوَحيد للكرة الأرضيَّة]])<br/>
        فضلًا عن 2,787 [[قمر اصطناعي|قمر صناعي أو ساتل فَضائي]] <small>(2020)</small><ref name=ucs>{{استشهاد ويب |مسار=https://www.ucsusa.org/resources/satellite-database |عنوان=UCS Satellite Database |عمل=Nuclear Weapons & Global Security |ناشر=[[Union of Concerned Scientists]] |تاريخ=1 August 2020 |تاريخ الوصول=27 September 2018| مسار أرشيف = https://web.archive.org/web/20190824003501/https://www.ucsusa.org/nuclear-weapons/space-weapons/satellite-database | تاريخ أرشيف = 24 أغسطس 2019 }}</ref>
        | الأبعاد =
        | التسطيح = 0.0033528
        | نصف_القطر_الإستوائي = 6,378.1&nbsp;كم
        | نصف_القطر_القطبي = 6,356.8&nbsp;كم
        | متوسط_نصف_القطر = 6,371.0&nbsp;كم
        | المحيط = 40,075.16&nbsp;كم&nbsp;(عند [[خط الاستواء]])<br/>40,008.00&nbsp;كم&nbsp;(على [[خط طول|طول دائرة الطول]])
        | مساحة_السطح = 510,072,000&nbsp;كم<sup>2</sup><br/>{{بدون لف|148,940,000 كم<sup>2</sup> من اليابسة  (29.2%)}}<br/>
        {{بدون لف|361,132,000 كم<sup>2</sup> من الماء (70.8%)}}
        | الحجم = 1.08321{{*10^|12}}&nbsp;كم<sup>3</sup>
        | الكتلة = 5.9736{{*10^|24}}&nbsp;كغ
        | الكثافة = 5.515&nbsp;غرام/سم<sup>3</sup>
        | جاذبية_السطح = 9.780327 م/ث<sup>2</sup><br/>0.99732&nbsp;''غ''
        | سرعة_الإفلات = 11.186&nbsp;كم/ث
        | اليوم_الفلكي = 0.99726968&nbsp;أيام<br/>23{{smallsup|س}}&nbsp;56{{smallsup|د}}&nbsp;4.100{{smallsup|ث}}
        | سرعة_الدوران = 1674.4 كم/س
        | الميل المحوري = 23°26'21".4119
        | المطلع_المستقيم_القطبي_الشمالي =
        | الميلان =
        | خط_العرض_الكسوفي_القطبي =
        | خط_الطول_الكسوفي_القطبي =
        | البياض = 0.367
        | درجة_حرارة =
        | وحدة_الحرارة1 = [[كلفن]]
        | الدرجة_الدنيا_1 = 184&nbsp;ك
        | الدرجة_المتوسطة_1 = 287.2&nbsp;ك
        | الدرجة_القصوى_1 = 331&nbsp;ك
        | وحدة_الحرارة2 = [[درجة حرارة مئوية|مئوية]]
        | الدرجة_الدنيا_2 = -89.2&nbsp;°م
        | الدرجة_المتوسطة_2 = 14&nbsp;°م
        | الدرجة_القصوى_2 = 57.8&nbsp;°م
        | النمط_الطيفي =
        | القدر =
        | atmosphere = yes
        | atmosphere_ref =
        | الضغط_السطحي = 101.325&nbsp;[[باسكال (وحدة)|كيلوباسكال]] ([[مستوى سطح البحر|مستوى البحر]])
        | مقياس_الارتفاع =
        | عناصر_الغلاف_الجوي = {{قائمة مخفية
        |title       =
        |frame_style =
        |title_style =
        |list_style   = text-align:right;display:none;
        |78.08%&nbsp;[[نيتروجين]] - N<sub>2</sub>
        |20.95%&nbsp;[[أكسجين]] -O<sub>2</sub>
        |0.93%&nbsp;[[آرغون]]
        |0.038%&nbsp;[[ثنائي أكسيد الكربون|ثاني أكسيد الكربون]]
        |حوالي 1% من [[بخار الماء]] (تختلف النسبة باختلاف [[مناخ|المناخ]])
        }}
        }}
        [[File: Cat.jpg | thumb | 220x124px | right | alt=Cat alt text | Cat caption text]]
        '''الأَرْض'''<ref>{{استشهاد بويكي بيانات|Q113297966|ص=1368}}</ref> ([[رمز فلكي|رمزها]]: [[ملف:Earth symbol (fixed width).svg|16px|🜨]]) هي ثالث كواكب [[المجموعة الشمسية]] بعدًا عن [[الشمس]] بعد [[عطارد]] و[[الزهرة]]، وتُعتبر من أكبر [[كوكب|الكواكب]] [[كوكب أرضي|الأرضية]] وخامس أكبر الكواكب في [[المجموعة الشمسية|النظام الشمسي]]،<ref>{{استشهاد ويب |عنوان=كواكب المجموعة الشمسية بالترتيب حسب الحجم |تاريخ الوصول=25 مارس 2020 |ناشر=موقع سطور|تاريخ أرشيف=2020-03-25}} {{مراجعة مرجع|تاريخ=أغسطس 2020}}</ref> وذلك من حيث قطرها وكتلتها وكثافتها، ويُطلق على هذا الكوكب أيضًا اسم ''[[العالم]]''.
        [[ملف:EpicEarth-Globespin(2016May29).gif|تصغير|22 صورة للأرض تم التقاطها من الفضاء عبر القمر الصناعي ديسكفر.]]
        تعتبر الأرض مسكنًا لملايين [[نوع (تصنيف)|الأنواع]] <ref>{{استشهاد بدورية محكمة
        | الأخير = May | الأول = Robert M.
        | عنوان=How many species are there on earth?
        | صحيفة=Science | سنة=1988 | المجلد=241
        | العدد=4872 | صفحات=1441–1449
        | مسار=https://adsabs.harvard.edu/abs/1988Sci...241.1441M
        | تاريخ الوصول=2007-08-14
        | doi=10.1126/science.241.4872.1441
        | pmid=17790039| مسار أرشيف = https://web.archive.org/web/20190321122146/http://adsabs.harvard.edu/abs/1988Sci...241.1441M | تاريخ أرشيف = 21 مارس 2019 }}</ref> من الكائنات الحية، بما فيها [[إنسان|الإنسان]]؛ وهي المكان الوحيد المعروف بوجود [[حياة]] عليه في [[الكون]]. تكونت الأرض منذ [[عمر كوكب الأرض|حوالي 4.54 مليار]] [[سنة]]،<ref name="age_earth1">{{استشهاد بكتاب
        | الأول=G.B. | الأخير=Dalrymple | سنة=1991
        | عنوان=The Age of the Earth | مسار=https://archive.org/details/ageofearth00unse | ناشر=Stanford University Press | مكان=California
        |ردمك=0-8047-1569-6
        }}</ref><ref name="age_earth2">{{استشهاد ويب
        | الأخير=Newman | الأول=William L. | تاريخ=2007-07-09
        | مسار=https://pubs.usgs.gov/gip/geotime/age.html
        | عنوان=Age of the Earth
        | ناشر=Publications Services, USGS
        | تاريخ الوصول=2007-09-20
        | مسار أرشيف = https://web.archive.org/web/20190531135529/https://pubs.usgs.gov/gip/geotime/age.html | تاريخ أرشيف = 31 مايو 2019 }}</ref><ref name="age_earth3">{{استشهاد بدورية محكمة
        | الأخير=Dalrymple | الأول=G. Brent | عنوان=The age of the Earth in the twentieth century: a problem (mostly) solved
        | صحيفة=Geological Society, London, Special Publications
        | سنة=2001 | المجلد=190 | صفحات=205–221 | مسار=https://sp.lyellcollection.org/content/190/1/205.abstract
        | تاريخ الوصول=2007-09-20
        | doi = 10.1144/GSL.SP.2001.190.01.14
        | مسار أرشيف = https://web.archive.org/web/20100205160041/http://sp.lyellcollection.org/cgi/content/abstract/190/1/205 | تاريخ أرشيف = 5 فبراير 2010 }}</ref><ref name="age_earth4">{{استشهاد ويب
        | الأخير=Stassen | الأول=Chris | تاريخ=2005-09-10 | مسار=https://www.toarchive.org/faqs/faq-age-of-earth.html
        | عنوان=The Age of the Earth | ناشر=[[TalkOrigins Archive]] | تاريخ الوصول=2008-12-30
        | مسار أرشيف = https://web.archive.org/web/20090218132039/http://toarchive.org:80/faqs/faq-age-of-earth.html | تاريخ أرشيف = 18 فبراير 2009 }}</ref> وقد ظهرت الحياة على سطحها بين حوالي 3,5 إلى 3,8 مليارات سنة مضت.<ref>https://www.ibelieveinsci.com/%D8%A7%D9%84%D8%AA%D8%B7%D9%88%D8%B1-%D9%88-%D8%A3%D8%B5%D9%84-%D8%A7%D9%84%D8%AD%D9%8A%D8%A7%D8%A9/ {{Webarchive|url=https://web.archive.org/web/20230307142018/https://www.ibelieveinsci.com/%D8%A7%D9%84%D8%AA%D8%B7%D9%88%D8%B1-%D9%88-%D8%A3%D8%B5%D9%84-%D8%A7%D9%84%D8%AD%D9%8A%D8%A7%D8%A9/|date=2023-03-07}}</ref> ومنذ ذلك الحين أدى [[محيط حيوي|الغلاف الحيوي]] للأرض إلى تغير [[غلاف الأرض الجوي|الغلاف الجوي]] والظروف غير الحيوية الموجودة على الكوكب، مما سمح بتكاثر الكائنات التي تعيش فقط في ظل وجود [[أكسجين|الأكسجين]] وتكوّن [[طبقة الأوزون]]، التي تعمل مع [[حقل مغناطيسي|المجال المغناطيسي]] للأرض على حجب [[أشعة الشمس|الإشعاعات]] الضارة، مما يسمح بوجود الحياة على سطح الأرض. تحجب طبقة الأوزون [[الأشعة فوق البنفسجية]]، ويعمل [[حقل مغناطيسي|المجال المغناطيسي]] للأرض على إزاحة وإبعاد [[جسيم أولي|الجسيمات الأولية]] المشحونة القادمة من [[الشمس]] بسرعات عظيمة ويبعدها في الفضاء الخارجي بعيدا عن الأرض، فلا تتسبب في الإضرار بالكائنات الحية.<ref>{{استشهاد بكتاب
        | الأول=Roy M. | الأخير=Harrison
        | المؤلفون=Hester, Ronald E. | سنة=2002
        | عنوان=Causes and Environmental Implications of Increased UV-B Radiation
        | مسار=https://archive.org/details/causesenvironmen0000unse | ناشر=Royal Society of Chemistry
        |ردمك=0854042652| مسار أرشيف = https://web.archive.org/web/20220712145137/https://archive.org/details/causesenvironmen0000unse | تاريخ أرشيف = 12 يوليو 2022 }}</ref>
        """
        XCTAssertEqual(insertedArticleWikitext, expectedInsertedArticleWikitext)
    }
    
    func testChineseImageWikitextIntoArticleWikitext() throws {
        let imageWikitext = "[[File: Cat.jpg | thumb | 220x124px | right | alt=Cat alt text | Cat caption text]]"
        
        let initialArticleWikitext = """
{{In-progress TV show}}
{{Infobox Television
| show_name = 和我老公結婚吧
| original_name = {{lang|ko|내 남편과 결혼해줘}}
| image = 내 남편과 결혼해줘 poster.png
| caption =
| show_name_2 =
| format =
| genre = 穿越、复仇、爱情、职场
| creator =
| based_on = {{原著|《和我老公結婚吧》|LICO、Sung So Jak}}
| developer =
| writer = 申儒潭
| director = 朴元國
| starring = {{SPML|[[朴敏英]]|[[羅人友]]|[[李伊庚]]|[[宋昰昀]]|[[李起光]]}}
| theme_music_composer = 朴成日
| country = {{KOR}}
| language = [[韓語]]
| num_episodes = 16
| runtime = 約59-66分鐘
| producer = {{ubl|金帝玹|刘相元|金东久|郭智勋}}
| executive_producer = 金伦熙、孙慈英、权庆贤
| produce_year = 2023年5月—2024年1月<ref>{{Cite web|date=2023-02-15|title=[POP초점]박민영, 전남친 관련 검찰조사..5월 신작 촬영 가능할까|url=http://www.heraldpop.com/view.php?ud=202302150930291642065_1|access-date=2024-01-11|website=헤럴드팝|language=ko}}</ref><ref>{{Cite web|date=2024-01-11|title='내남결', 오늘(11일) 촬영 끝→결말 함구령[★NEWSing]|url=https://www.starnewskorea.com/stview.php?no=2024011110130556427|access-date=2024-01-11|website=스타뉴스|language=ko}}</ref>
| cinematography = 文明焕、金基勋
| editing = 金秀珍、全贤贞
| location =
| company = {{ubl|[[Studio Dragon]]（企划)|DK E&M}}
| distributor =
| channel = [[tvN]]
| picture_format = [[高清电视|-{zh-cn:高清电视;zh-hk:高清電視;zh-tw:高畫質電視;}-]]
| first_run =
| first_aired = {{Nowrap begin}}{{Start date|2024|1|1}}
| last_aired = {{End date|2024|2|20}}
| related =
| website = https://tvn.cjenm.com/ko/Marrymyhusband/
| 台灣名稱 =
| 港澳名稱 =
| imdb_id=26628595
}}
《'''和我老公結婚吧'''》（{{韓|諺=내 남편과 결혼해줘|漢=내 男便과 結婚해줘}}，{{lang-en|''Marry My Husband''}}），為[[韓國]][[tvN]]於2024年1月1日起播出的[[TvN月火連續劇|月火連續劇]]，改編自同名網路小說，目前已連載為網路漫畫。<ref>{{Cite web|last=신은주|title='전남친 구속' 박민영, 컴백 임박..."'내 남편과 결혼해줘' 검토 중" [공식]|url=https://entertain.naver.com/read?oid=213&aid=0001244939|access-date=2024-01-01|website=entertain.naver.com|language=ko|archive-date=2023-10-25|archive-url=https://web.archive.org/web/20231025143939/https://entertain.naver.com/read?oid=213&aid=0001244939|dead-url=no}}</ref>由《[[朝鮮精神科醫師劉世豐]]》的朴元國導演執導，《[[日與夜 (電視劇)|日與夜]]》的申儒潭編劇執筆。講述因至親與丈夫的背叛而迎來悲劇性結局的女人，回到十年前將自己悲慘的命運還給他們的「第二次人生」。<ref>{{Cite web|author=오명언|url=https://www.yna.co.kr/view/AKR20231025041400005|title=tvN 드라마 '내 남편과 결혼해줘'에 박민영·나인우|website=[[韓國聯合通訊社]]|date=2023-10-25|accessdate=2023-10-28|language=ko|dead-url=no|archive-date=2023-10-27|archive-url=https://web.archive.org/web/20231027194747/https://www.yna.co.kr/view/AKR20231025041400005}}</ref><ref>{{Cite web|author=최지윤|url=https://newsis.com/view/?id=NISX20231025_0002495374|title=박민영, 전남친 구설 딛고 복귀…'내 남편과 결혼해줘'|website=[[紐西斯]]|date=2023-10-25|accessdate=2023-10-28|language=ko|dead-url=no|archive-date=2023-10-27|archive-url=https://web.archive.org/web/20231027194752/https://www.newsis.com/view/?id=NISX20231025_0002495374}}</ref><ref>{{Cite news|url=https://www.sportsseoul.com/news/read/1385374|title=‘내 남편과 결혼해줘’ D-1…박민영·이기광, 짜릿한 인생 역전극|publisher={{lk|首爾體育報|스포츠서울}}|language=ko|date=2023-12-31|accessdate=2024-01-01|archive-date=2024-01-01|archive-url=https://web.archive.org/web/20240101073603/https://www.sportsseoul.com/news/read/1385374|dead-url=no}}</ref>
"""
        
        let insertedArticleWikitext = try WKWikitextUtils.insertImageWikitextIntoArticleWikitextAfterTemplates(imageWikitext: imageWikitext, into: initialArticleWikitext)
        let expectedInsertedArticleWikitext = """
{{In-progress TV show}}
{{Infobox Television
| show_name = 和我老公結婚吧
| original_name = {{lang|ko|내 남편과 결혼해줘}}
| image = 내 남편과 결혼해줘 poster.png
| caption =
| show_name_2 =
| format =
| genre = 穿越、复仇、爱情、职场
| creator =
| based_on = {{原著|《和我老公結婚吧》|LICO、Sung So Jak}}
| developer =
| writer = 申儒潭
| director = 朴元國
| starring = {{SPML|[[朴敏英]]|[[羅人友]]|[[李伊庚]]|[[宋昰昀]]|[[李起光]]}}
| theme_music_composer = 朴成日
| country = {{KOR}}
| language = [[韓語]]
| num_episodes = 16
| runtime = 約59-66分鐘
| producer = {{ubl|金帝玹|刘相元|金东久|郭智勋}}
| executive_producer = 金伦熙、孙慈英、权庆贤
| produce_year = 2023年5月—2024年1月<ref>{{Cite web|date=2023-02-15|title=[POP초점]박민영, 전남친 관련 검찰조사..5월 신작 촬영 가능할까|url=http://www.heraldpop.com/view.php?ud=202302150930291642065_1|access-date=2024-01-11|website=헤럴드팝|language=ko}}</ref><ref>{{Cite web|date=2024-01-11|title='내남결', 오늘(11일) 촬영 끝→결말 함구령[★NEWSing]|url=https://www.starnewskorea.com/stview.php?no=2024011110130556427|access-date=2024-01-11|website=스타뉴스|language=ko}}</ref>
| cinematography = 文明焕、金基勋
| editing = 金秀珍、全贤贞
| location =
| company = {{ubl|[[Studio Dragon]]（企划)|DK E&M}}
| distributor =
| channel = [[tvN]]
| picture_format = [[高清电视|-{zh-cn:高清电视;zh-hk:高清電視;zh-tw:高畫質電視;}-]]
| first_run =
| first_aired = {{Nowrap begin}}{{Start date|2024|1|1}}
| last_aired = {{End date|2024|2|20}}
| related =
| website = https://tvn.cjenm.com/ko/Marrymyhusband/
| 台灣名稱 =
| 港澳名稱 =
| imdb_id=26628595
}}
[[File: Cat.jpg | thumb | 220x124px | right | alt=Cat alt text | Cat caption text]]
《'''和我老公結婚吧'''》（{{韓|諺=내 남편과 결혼해줘|漢=내 男便과 結婚해줘}}，{{lang-en|''Marry My Husband''}}），為[[韓國]][[tvN]]於2024年1月1日起播出的[[TvN月火連續劇|月火連續劇]]，改編自同名網路小說，目前已連載為網路漫畫。<ref>{{Cite web|last=신은주|title='전남친 구속' 박민영, 컴백 임박..."'내 남편과 결혼해줘' 검토 중" [공식]|url=https://entertain.naver.com/read?oid=213&aid=0001244939|access-date=2024-01-01|website=entertain.naver.com|language=ko|archive-date=2023-10-25|archive-url=https://web.archive.org/web/20231025143939/https://entertain.naver.com/read?oid=213&aid=0001244939|dead-url=no}}</ref>由《[[朝鮮精神科醫師劉世豐]]》的朴元國導演執導，《[[日與夜 (電視劇)|日與夜]]》的申儒潭編劇執筆。講述因至親與丈夫的背叛而迎來悲劇性結局的女人，回到十年前將自己悲慘的命運還給他們的「第二次人生」。<ref>{{Cite web|author=오명언|url=https://www.yna.co.kr/view/AKR20231025041400005|title=tvN 드라마 '내 남편과 결혼해줘'에 박민영·나인우|website=[[韓國聯合通訊社]]|date=2023-10-25|accessdate=2023-10-28|language=ko|dead-url=no|archive-date=2023-10-27|archive-url=https://web.archive.org/web/20231027194747/https://www.yna.co.kr/view/AKR20231025041400005}}</ref><ref>{{Cite web|author=최지윤|url=https://newsis.com/view/?id=NISX20231025_0002495374|title=박민영, 전남친 구설 딛고 복귀…'내 남편과 결혼해줘'|website=[[紐西斯]]|date=2023-10-25|accessdate=2023-10-28|language=ko|dead-url=no|archive-date=2023-10-27|archive-url=https://web.archive.org/web/20231027194752/https://www.newsis.com/view/?id=NISX20231025_0002495374}}</ref><ref>{{Cite news|url=https://www.sportsseoul.com/news/read/1385374|title=‘내 남편과 결혼해줘’ D-1…박민영·이기광, 짜릿한 인생 역전극|publisher={{lk|首爾體育報|스포츠서울}}|language=ko|date=2023-12-31|accessdate=2024-01-01|archive-date=2024-01-01|archive-url=https://web.archive.org/web/20240101073603/https://www.sportsseoul.com/news/read/1385374|dead-url=no}}</ref>
"""
        XCTAssertEqual(insertedArticleWikitext, expectedInsertedArticleWikitext)
    }
    
}
