'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "4f742c2a46aee71b1f2bf6ab8e7017e4",
".git/config": "e29c9b8310832ec5573403e02fe95efe",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "013f073889cb8d3d23aea2663408e9d8",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "305eadbbcd6f6d2567e033ad12aabbc4",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "73c492a8c6f34865298a24ff1d9495b5",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "2aec711efd31b3184a1fa518d21c54a8",
".git/logs/refs/heads/build": "99da79a7bcf4914293fe17b168a52816",
".git/logs/refs/remotes/origin/build": "5a63dc7fdba92f57f3355957fec56279",
".git/objects/01/1842b856d2844c35f671e492a3793c1dea487f": "9a7fa59443b8925d7b787ea6939b9d2f",
".git/objects/02/1d4f3579879a4ac147edbbd8ac2d91e2bc7323": "9e9721befbee4797263ad5370cd904ff",
".git/objects/03/eff19317968ec80cd13779db4fa85dd324751f": "4b775157b07af4b65102da4181d11a9c",
".git/objects/04/1017e9fb3d7299ea95347da574fdb81b141fb6": "7f4d6428289126bf6381506089a6ef6b",
".git/objects/05/a9c09613574de9b77071261d4429ad6457f4f3": "ac4627b63d6bbc4a63e59c613b45193e",
".git/objects/09/bc8a8e2b468a355af4d35d16aab3efc553a638": "94bc8d655ebcd0186743576173a04f04",
".git/objects/0d/2d5d7b1619843591d9b4bfcceb1284c87edd5c": "db053bd3e2d0a9df0594b76a1fe9e89b",
".git/objects/0d/67a4ee228f37023533e7c94cbb88668bd72e9d": "6e6c65bc7fea91133ddfa637a9efebe0",
".git/objects/13/02871d42b13aef48f51cb78d1b0d967838efa8": "2fcf70f7eaeebff9a49457d5ab3b2486",
".git/objects/14/a7ef20239bec04ffa04ff3f3c49e2fded4f738": "c74ad7e20fb6e6379803d66b3d6430d7",
".git/objects/19/e2d8863b34cc446509e3cc388adeba0fca8788": "82a8d897def99f3bce10a4f735c610d3",
".git/objects/1b/8574ac978d2848fa84bb6ff57f9209f07ae847": "9b1e25d7353ca627fbb23c2e3bb973e2",
".git/objects/1e/1fa8ca24aff4405aff497c6eeb8bb32e96e822": "1f9d97feffc663438971b934be9762ef",
".git/objects/1e/54a86f80eec9b3da9d72d436cef5639fa8dc66": "3ec681bd76761614c211bd24c8cc4cee",
".git/objects/1e/fdb6b10d5e202c0dacc419df16b5050e6c6263": "6cba4eee6256174ab549501ec399b115",
".git/objects/1f/c993bb56031b8c1b9f9afda405cd30f80e0ef9": "77ca7acf7f5a98b0ea459d0afba5c6a3",
".git/objects/20/3a3ff5cc524ede7e585dff54454bd63a1b0f36": "4b23a88a964550066839c18c1b5c461e",
".git/objects/21/56f06ff8266f2917d53d4bac99565933a89ce8": "c15b3ee5a04431c3ee9d120c027d38bc",
".git/objects/21/a0c19d25a6769a36f92f23239abf9e5839611d": "d6e024b5022f1fa32a1dd6be7424dc3e",
".git/objects/27/2f3f0a688adefc68d82182210258530c561178": "4df08d239faaba6b420ef0e43145766f",
".git/objects/27/acb2a9d551a40b805f25f79d43d020e719b109": "13d8f568961c1accdab4b39a4cd19724",
".git/objects/28/6a48c5a453d73fb5ce555f9a0656a923e22e96": "99f80d4c240a77ee916c880b7fc4f03d",
".git/objects/29/f22f56f0c9903bf90b2a78ef505b36d89a9725": "e85914d97d264694217ae7558d414e81",
".git/objects/2a/02280ff5bb13cc211692e63dd053e4c24c6002": "6b48bc287a7627a8cb78e5bd07b1e88e",
".git/objects/30/6942dc5bda024438722d4da845f397d2b10e14": "682a06660c7a1bece06811374e7444ab",
".git/objects/35/4bda81f267ad72409fbfc3b2f9f61dc7c0fdd4": "59165827cc8dc6060eb5f3229972b7bb",
".git/objects/37/39df198eb66d2f6019f8f4ec3d7975e14b7159": "86a977c5cfb8a4c8a2eb752f6958da07",
".git/objects/38/3844ad31ca6da500cc2bef06ad42ec0e3ecae1": "234d0134b6a5bd8b0d1e899660670c78",
".git/objects/38/474e722faf0d122c53375c7cc579a50e4e503f": "0499a56357ec1afa84c508374355adf4",
".git/objects/38/f7b7727c028b18463881003f90400449f4decc": "00dbc64ef1d4f9f09bc0481c6a385d51",
".git/objects/3b/ef657aa52a5bfad893603b087ddfa81fff7269": "c9b9bf480f3369152370a08d7d96e4aa",
".git/objects/3c/519325bf4a6f671402fc27ea29f272f37328fd": "d42dd12c97009395fdc1c95d84b4def7",
".git/objects/3f/d7153b729f50e14875dfbdf5cdfc3e5432b507": "f95ca8a13b5556fad9f1e1ed417d8a8e",
".git/objects/3f/eae526bb483b57df02280fc9c13d7cbd189333": "420b26a599fe98e6906210b935fec59a",
".git/objects/40/9f4c96f4d32fa8c540b6d1f69960570b3b7312": "d364a83bfe14ba199a3fe41f3d97cd51",
".git/objects/40/a0da01102ceacdb305b714c0d1f36a7d08d448": "04994a5c0651118b6b453adfe59565b2",
".git/objects/41/d0c2a2c9e7744398d7ac282c261e699dcbaa18": "83fc2cc306ca5352d53a6dabf2dcec24",
".git/objects/42/a735c84aaae1744e4a82bdcd264ee8a67292dd": "7dd77e95b0d54a835d1faf2b93a77a6d",
".git/objects/47/84f9b8bf1903eeab24ef2fc1ff8e0dd76cd61c": "d8a60d5a51510a5d8ffd00199a324545",
".git/objects/48/1b989adb9a2fff46e0d7f95dca83befa57b7c6": "9937f230742619a30b17b23966581bea",
".git/objects/49/0117c0460351b67028e26e56d25785813d7312": "b6cf2f4145182eacc0fb955128fff5cb",
".git/objects/49/a3160710efaabc8c865f2e93627be5c0d928fa": "e77031a8ed7a7aa88b732bf2913dbcf6",
".git/objects/49/f7d4b3c7f11575c18da76baf6126af5dc50fd4": "b1f4803b23aff24fe4dfc22efcea9738",
".git/objects/4a/5455ff9e17edde54e4bf37f98cdff939840a04": "cb84cb15d6fdda78c100f4c6a555a5e9",
".git/objects/4a/c43a859a928f417f3de03513eb5945aa1abc8c": "a6cef283d2ed4fd6ccc9f4f23ac7b524",
".git/objects/4b/eecdb03e854ff134157982983b181f4246c248": "23e2ac7dafd541a56f274473f247feb2",
".git/objects/4c/8e5e577a27300c085116d83b725f71bcdacfbf": "9f4283b05643e7cdd28c27f7ec362756",
".git/objects/4d/9ddd5511188edd505b10d8e51fd55a605aa723": "7c23d57dd72325d96d223b13fab8e597",
".git/objects/4d/bf9da7bcce5387354fe394985b98ebae39df43": "534c022f4a0845274cbd61ff6c9c9c33",
".git/objects/4d/dd4df143f6941e9e14656178d03b024efd5420": "ac61e4b398d1e68750cade9c677ba64a",
".git/objects/4e/0d9f8efb86f69fce020088c7bb426809057e80": "f37c92205b1ebd3f3903b5632beaf235",
".git/objects/4f/fbe6ec4693664cb4ff395edf3d949bd4607391": "2beb9ca6c799e0ff64e0ad79f9e55e69",
".git/objects/50/11dac886c90fcb2ce2a8f6d383dc8272ef7ce7": "17fd77105bb23d2c731b793c6eef939a",
".git/objects/50/221208d337407e75378c0d6e093938d988ab41": "369c9ec0059ca126f0bf35069dd7a54c",
".git/objects/50/29c2948d8b47965e3d83266b9ca5ed62136681": "f66a5ab1aad30118652a14dac8247b6a",
".git/objects/52/4de61b5fe28819791018b630aed3fbbd9d4b9e": "b030ce186f85af1bcb990c029ba9ce11",
".git/objects/53/e225ee8f69609dab29dc01fdcc9547dc2fa2e4": "27318afb8b3fa87dff16489932ee69a4",
".git/objects/55/13cd6a1702ec4a93c0b68a5f49e7cb01859722": "d42c2006bffcea4d60a1c2aafa85fd9c",
".git/objects/57/7daf3262933337b0f00ec61b535c5a550b1089": "3d9601b51aea8129ce2c281c7664972b",
".git/objects/58/a087a4d9727bd21ed2f719349c71785a1d012b": "2b0282de03d85f3715e9dda83ca741d8",
".git/objects/5a/72cf8aef2d07d18eab58b1bf577a69b1f2e588": "1d2b12cdf181c6844a9b548d5ced8b7b",
".git/objects/5c/255f21bec1f2e94197e55a41685ff7e128a243": "7043d7667fa3a36f8bb58c210da7a346",
".git/objects/5e/8448cfdd8ff56e1090bdec7886e124dc40e632": "bb77138b3a7314f7a73f388f2a84d9ad",
".git/objects/60/4a5d24179fc7e45ed06490ddea65df650ff54b": "2a8dbe5c38038b734bdab7296293aa93",
".git/objects/63/57d233ca5290abf1b1f769797611c0b8335f24": "d0912e1629c037a8d77d12ddf4a05433",
".git/objects/63/f9b43e8fb241bf40b4d0d83f4d02977d6c7f7e": "47e44fddb98694b4f77a16895f5a719a",
".git/objects/66/24c36229d308674c0d49bd4d8d08f4b1e47634": "b566aa734030256cd18db7b0401a8318",
".git/objects/69/186b3cf50ec095ccca5e77f339139fbb7d77a0": "e23fd2239b282c108e49bd947b0f4bb1",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/6d/cc48f25d1cde78d6ffbfcfb511103d53d32516": "606411361328517a554ece172be65ef9",
".git/objects/6d/cf31bc8069845aef6f7808a0c461c6671b1d30": "a72c2111019e2de35583b441d1668093",
".git/objects/6d/f204276029d83caa733f638116fd426feda726": "039bfeb48448294b592dbe5f8a38f783",
".git/objects/6d/f2b253603094de7f39886aae03181c686e375b": "4e432986780adf1da707b08f0bc71809",
".git/objects/6f/d821fedef38c9e304a28bb4146710f5cbe8ef6": "ce1f1f5d142c3befaee605017e2b6ffc",
".git/objects/70/a65e0dd0adffc65df919322b51968f2f7b030a": "8f461e1488200a1407f1a762cdc8d712",
".git/objects/72/bc37e34c87a700c7558c2afb0d35931f77a819": "328d544ba414ab74163eb3da5d18f653",
".git/objects/73/5fe05d2d9072b1c725a7c5304bd56445371b1e": "60897b768b1848dede52743f3835bccd",
".git/objects/7a/6c1911dddaea52e2dbffc15e45e428ec9a9915": "f1dee6885dc6f71f357a8e825bda0286",
".git/objects/7b/536bca4c51ccb98db6f12e44f308fcde7b3f06": "f253ef6d2d0f8a4a529a9b4337e8295b",
".git/objects/7c/333cf43abeee3ef5331b5d9abc706a584b29cf": "6245e4f48e6b1ee4b1645d5fd33763f8",
".git/objects/7d/d486bf03df863fe7a696bc37924b5525578148": "4637223705e66e6da53290504f1bff44",
".git/objects/7e/3bb2f8ce7ae5b69e9f32c1481a06f16ebcfe71": "4ac6c0fcf7071bf9fc9c013172f9996f",
".git/objects/82/2ec5485225de10e2c8edf8d0cf31fe53e69a32": "ad1a10cd35dbbbf79702ea4b57edff5c",
".git/objects/86/0fad84b734ab4f7212bd798e93268a1a58e4bb": "eb9bf255db2f24ddd9c59a1b4fef5904",
".git/objects/86/34a97c911ebed728ca5d3ca1ecbd526e7e6533": "a19c71a985a50a082c95d30c9c7ade17",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/a42788fa7d2cf315a408ad26185422170cf287": "3f9f16c1aee82be4e79931ce7a57f50d",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/8c/8f210d95082d6ebec598c04cf38bc232594aae": "c97cc8f071ab8abb29cf6591be84d818",
".git/objects/8e/31d5eeb09a7f834e138646bb221b48fd73bd71": "eefdcdf3c29736249c3c00f4a7bbb2af",
".git/objects/8e/558cd57838525f23e218a63a1361a28680ef93": "ad115b6afc5cfc770677921e1650553d",
".git/objects/8e/de1a4b89b1017da7beeadb3d9ed4b62515e6a6": "9c7188cf8a73a64fe01728d90d201967",
".git/objects/8f/cd4aa910cf0f2c6e315f7a17f0089f72fc1dfa": "e274b3a8209289df50273f4931783f6e",
".git/objects/93/544fda037e34ad560033df26c647394bb7ae3a": "3297a601d62bf33295e228dcb554da0f",
".git/objects/94/cc3dacd05876313731d0d56a1b81d021249f4c": "7b3e587aa38f91166229ecc3342cd485",
".git/objects/94/fec25f93c49283da78808d7e3c789dc34734f8": "25619784d9758024d7ddbf0b4f7ab02c",
".git/objects/96/d00c8218d3298eb6bd576e2f93adbb3efb3494": "e82c29238824ebc2f88746e9a716a5d1",
".git/objects/97/34888639d07fcd9ecc5e1bd9fec19e41d5a5d6": "f7487ac347d5c742088c7467a6776d74",
".git/objects/98/0d49437042d93ffa850a60d02cef584a35a85c": "8e18e4c1b6c83800103ff097cc222444",
".git/objects/98/5cd8c0147a3a7438bc4451e43952de10ff3f43": "099949018aea93a74930a96d1130b6bb",
".git/objects/9b/3ef5f169177a64f91eafe11e52b58c60db3df2": "91d370e4f73d42e0a622f3e44af9e7b1",
".git/objects/9c/90dcd025b3c1e1c50a0490161f6e9d871bc354": "481142cefaabd750feb78cc4ac9ac808",
".git/objects/9c/9c3f85984480c9d1d5f53dd70249dc8cba441f": "6f69490c313e4f0f10f3fe7a71bb5add",
".git/objects/9e/3b4630b3b8461ff43c272714e00bb47942263e": "accf36d08c0545fa02199021e5902d52",
".git/objects/a1/a8cedb3a9b2be86045c114d53da074eada9af5": "eef38ee6d18377ca7cc5dc543bb3f264",
".git/objects/a1/e99e8600c9989f2961640add32291a791c10b3": "b4c7869f9c75309e70d0d0f170b91512",
".git/objects/a2/7c9ebdff4bd6dfb8db32b29bf9d722ff22228b": "7354a992ae9ccc40bd8843291b122e47",
".git/objects/a5/40cbdc2b00545c0f756712983c455561ebad3a": "a726489ac8f9b4b6e438f657f4ff554d",
".git/objects/a6/4b6be18fac9ce43d43f6b7efddd2069c8b1297": "f01aa4654a9bd434f21b6023b9974252",
".git/objects/a6/7af5ca98a8f187ce3fa0cdc1d8876a51ee7500": "4dbe066002ef0a877b9054d23d488763",
".git/objects/a9/3364e9f50dc95ce7b20c1d2a24dd2c76ae38a8": "bcb29946800f5877a853e94506ca993f",
".git/objects/aa/c319c7cf27457bdd2f441bbf6878860b8f5eef": "47825bda39e46f6b4ba1ddb42ecb8e9b",
".git/objects/ac/c759286f52b225b0bd7c69b7fa0ce3af7c8c95": "14f82d39170b599eee89f6fc5424b9d4",
".git/objects/af/2836f9796cab14a1b0a6c24b30ee6af00b1bdb": "3e46ab3365a0944c0695255049b7473f",
".git/objects/af/f61cbf04451de9997facc375ed744c74020465": "f2b0a9b69956256344b7825fea870fbb",
".git/objects/b3/60e8b81f63c705fbed202fc16da8ac7027aef5": "148603f07eadec0379d8b7420a544093",
".git/objects/b6/b8806f5f9d33389d53c2868e6ea1aca7445229": "b14016efdbcda10804235f3a45562bbf",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b7/7e1fbe5ce257778efe289f639c941515588e3a": "33133bd4f136f6a4c03a98326c524e50",
".git/objects/b8/64e5d0841ef9ec2412c4f2d30c3502f83dad27": "3eb05b11b6517cf8c0e245553bdc9050",
".git/objects/b8/d6c0eb53898fc325332cf8c859e0c7f737d1fa": "ff7fab5bf9d2ca9773261d6fc3f1e298",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/bb/c042d0ed3213504cfaa20b3c74839b5aa7d1ee": "d3345511968d898e3b516f0f5000138f",
".git/objects/bc/fb75114d1c1124384a13f8cfc678ed6e33556e": "2693938184575303cd18e74ccf2e1fa5",
".git/objects/bd/4521d75fe6c8acab2e0b95f3c75f3a050766a4": "1859ca837e92cb8cde5d9773622d0f73",
".git/objects/bd/b00e6faa9a0e6e5c36cbae405dae4a5bd73e51": "5fbdc7629e53bc2bc89261437bf2f572",
".git/objects/be/fce6af890a4edf6d3c858878b30c1c2e2cd803": "a6c70daafc28408c562234b3d09e0578",
".git/objects/bf/a8e68c60d9be893fcc00a9daddd668b1c4b26d": "0f70c6abe67fa76c9b5502ff1a21d7a9",
".git/objects/c2/2a70af395905cf557dbc752227a846dbf57f60": "5ba91c9f1b2d081a5704053e9bb04614",
".git/objects/c4/016f7d68c0d70816a0c784867168ffa8f419e1": "fdf8b8a8484741e7a3a558ed9d22f21d",
".git/objects/c8/34046b2257a5afe770a685f52cfdf5876b227b": "1bc8faf844aadf27f7b9fd072e867d51",
".git/objects/ca/3bba02c77c467ef18cffe2d4c857e003ad6d5d": "316e3d817e75cf7b1fd9b0226c088a43",
".git/objects/d1/3ac057f51483d5af5322b2a0cac288118c84b4": "fb090317f5f08ced9c134f39269717ed",
".git/objects/d1/9b8dc07b5058244a7c9770f11447f440616a90": "ddceaea4a2f6c159ad8a0adb1dfe977f",
".git/objects/d2/16282a2f23ab1779b1b5c99b7245bf50b14454": "31311855814085f1fb670bfa99aab4cb",
".git/objects/d2/5dee95e43eb439df3fd4f01e7ff38672012035": "1d6f33c180b336f726f1a690a819d5f9",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/da/2b4639388dbeb69841d6833be3278e6b55e6c4": "3195abc9a933759d0169bf5c0a11e8df",
".git/objects/da/9b4e1c686a80ecd20a48ea86c4dafde361a5c8": "af19069db39e8b457298d5265275d1af",
".git/objects/db/bd03e0f8a92a8019cba3dec733fb23d5ec1add": "d7ee462327b28eda0f847b09afd92d31",
".git/objects/dd/3745a43b896f15159473f657d312086490e2cd": "44e434bb1a87dfe9a9bdf57fd87e83fb",
".git/objects/dd/ecb254e20dc1e0b9f38661ea8655cb20510b71": "0adb612949b1beb50f35d8471b3965e2",
".git/objects/dd/ff7018e031fb083044dcc2477d3810f9835527": "7e26ca94ab5a8c26c9fb92b466003926",
".git/objects/e3/e9ee754c75ae07cc3d19f9b8c1e656cc4946a1": "14066365125dcce5aec8eb1454f0d127",
".git/objects/e6/2450a1f2c465ee824ddda3c2c92188128c9cce": "7c11de59fc6b99c62b1c1af596fff0ee",
".git/objects/e9/1521e517ab2797bafa1a465c7e193290a13ea0": "154ebd8c1c39aa04c654701e3a125879",
".git/objects/e9/6ec04d6bf5d7605dc8d26acba8a7cb7faf24a7": "d8efa9dfd0cb5e9a1d0f27e705edc6a0",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/ea/e99bd592af4f8aefa385f42bf1ab487df70cc3": "07de33f75473ec4f6a2e21da8685edba",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ed/831e22c6289b75b761eb615576715d0576ee12": "5f88000162d59157c6ba60ca685c6509",
".git/objects/ed/aef00c4e60fb3fdfadbef8815582ee3f101751": "8acf653351031f7670f98c4127b8e820",
".git/objects/ed/b55d4deb8363b6afa65df71d1f9fd8c7787f22": "886ebb77561ff26a755e09883903891d",
".git/objects/f0/638e92c24472550c9b72431eafda6011cb67aa": "8aac9070f42b3c85f72097b81732ef04",
".git/objects/f1/7226ff1a3685f49532d3349cd3d8c798531478": "f35ebbf4b0fb2c9f1abcbb572dcd5b38",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f2/c9ebab0d53e1f95e6b4943880321d0dc187ade": "88908e835f3a41103cb8bf0c6848b093",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/f6/0b3e3d6d283d2ca38ccdb8677b0c863434d1b2": "10d0d1b4b89d8d0db8ea31e9d56b5320",
".git/objects/f6/1f6e584282318017cf0a31e5680651660d2a95": "d419a83900be6a98761ab3553ad287cc",
".git/objects/f6/c72143897c5eabb59d64cc02bc29bb5c9e601f": "1144b62475364cda76fc3ce2b5569abc",
".git/objects/fb/37f128cd04884ed641a51195c8857c57ff8512": "d6107c0c120832baa2d22ce7588695c1",
".git/objects/fd/1fedf312e32aec5dd616340f86adb6dba94e83": "daf218acca16a7c99b770dd9c555b88f",
".git/objects/fe/3b987e61ed346808d9aa023ce3073530ad7426": "dc7db10bf25046b27091222383ede515",
".git/objects/fe/6c208c529635eb557af6fbaf73320023e6a5a3": "9722a39036706f5fa04994670350a29e",
".git/objects/fe/ef09b635e13007ef4f68f76f8608bcea16c859": "262aa35037792cc3bec7860142f1acf1",
".git/refs/heads/build": "26fbc01a93b6711207ca8419fc245fae",
".git/refs/remotes/origin/build": "26fbc01a93b6711207ca8419fc245fae",
"assets/AssetManifest.bin": "e8224f46de21fdae0eb9f95d5d2a12db",
"assets/AssetManifest.bin.json": "33702dda4ed52f235575e842c22db4f0",
"assets/AssetManifest.json": "a25481508c5bdc18192c12749fea7f9a",
"assets/assets/fonts/Roboto/static/Roboto-Regular.ttf": "303c6d9e16168364d3bc5b7f766cfff4",
"assets/assets/loginbg.png": "55e179705ece46d4db3edc20b301e7d6",
"assets/assets/LogoAlphaOmega.jpeg": "41557cc792d92341475d0a8d5444f549",
"assets/assets/logoalphaomegapng.png": "6a84d0937fffefbb1c2f25fadf325ddd",
"assets/assets/sounds/cashier.mp3": "992ac57b49ed41a761fa667f821878f9",
"assets/FontManifest.json": "2b52acee7bee9f34d372a965ef37754f",
"assets/fonts/MaterialIcons-Regular.otf": "62fa5b494aecf445caffc7e87f6a47ee",
"assets/NOTICES": "7236f6e159e5f1d432c423cb1418fa18",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/syncfusion_flutter_pdfviewer/assets/fonts/RobotoMono-Regular.ttf": "5b04fdfec4c8c36e8ca574e40b7148bb",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/highlight.png": "2aecc31aaa39ad43c978f209962a985c",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/squiggly.png": "68960bf4e16479abb83841e54e1ae6f4",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/strikethrough.png": "72e2d23b4cdd8a9e5e9cadadf0f05a3f",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/underline.png": "59886133294dd6587b0beeac054b2ca3",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/highlight.png": "2fbda47037f7c99871891ca5e57e030b",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/squiggly.png": "9894ce549037670d25d2c786036b810b",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/strikethrough.png": "26f6729eee851adb4b598e3470e73983",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/underline.png": "a98ff6a28215341f764f96d627a5d0f5",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/sounds/cashier.mp3": "992ac57b49ed41a761fa667f821878f9",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "62a355ad786ceaf657c7b221a5d967cf",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "38d0b52ee2a1697450e55cf2a48ead05",
"/": "38d0b52ee2a1697450e55cf2a48ead05",
"LogoAlphaOmega.jpeg": "41557cc792d92341475d0a8d5444f549",
"logoalphaomegapng.png": "6a84d0937fffefbb1c2f25fadf325ddd",
"main.dart.js": "272f8fe0ff777e4b9e10a127da62e3b2",
"manifest.json": "0030ff64be1c3181710c3014b11018a8",
"OneSignalSDKWorker.js": "0c4961658e1529c49544481dddc8b012",
"version.json": "2b521e10dfa0f067561de489a19d6620"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
