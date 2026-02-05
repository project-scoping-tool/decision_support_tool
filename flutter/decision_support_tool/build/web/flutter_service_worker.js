'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "e4c343ae7b65545f838081cba1208c38",
"version.json": "37dbbab8a551aec1f3f607ea2a482212",
"index.html": "426c4f12ee14178a223e919dbde1e49c",
"/": "426c4f12ee14178a223e919dbde1e49c",
"main.dart.js": "293a392a51d29884d3ea39ed3fe0b3ad",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "9ea14516d7408fa3bec72d6b351b4a88",
".git/ORIG_HEAD": "eeccada87f4601e479d032c44ce9997e",
".git/config": "f4c62b3678c3dcbd57fe1c6bc90bd086",
".git/objects/0d/19298c28e8c688797cfbd712717b67aeda8e7d": "be33ae5162f75521f36f0ecd6c78651a",
".git/objects/92/fa2554ea3709cb51553008cea926184289a27b": "bdba7b248eb765d58df099f742500405",
".git/objects/50/fb005fc9631098b48e429727b2349ea3b26f92": "8ecc022e49094927ef7ffe36ef1b8d91",
".git/objects/68/43fddc6aef172d5576ecce56160b1c73bc0f85": "2a91c358adf65703ab820ee54e7aff37",
".git/objects/57/9b6f93600c2a37af215a3da3c288f09feb3330": "f777f58257a27a5bcaef9a77bdb51e57",
".git/objects/57/3876470a85a410679f6c5095b2fdac4a21aa0e": "856960d685f9e971b77ddc15cdfd7ef9",
".git/objects/57/811fe98e1f649f7289618cc7850458913c1fc8": "34474e65b3eac989592b8d15c88d3079",
".git/objects/6f/7661bc79baa113f478e9a717e0c4959a3f3d27": "985be3a6935e9d31febd5205a9e04c4e",
".git/objects/9b/7057c37bba9d87782e9e84548f88f808ae62e2": "4553cf1b2a39ec823771037b85ceb5e5",
".git/objects/04/2c896f7227b64844c11c18f74a2a080d596c49": "4b6ff21643a0c25067991ebd428086cd",
".git/objects/04/3f3388a40f05a0cda8a2df8444fb93a3c6eb71": "dd2435552f97c3ee5ecaca9b344a8cbf",
".git/objects/6a/1c8e1759d9b630740cae582aafa4e2a570fd9c": "b185a134e9ffddeba083be9bc0f5d01e",
".git/objects/69/b2023ef3b84225f16fdd15ba36b2b5fc3cee43": "6ccef18e05a49674444167a08de6e407",
".git/objects/3c/98ac9761491f9501fe6adc345ec13344351d47": "4d55447006c02ca6fc8a4ddd2c9b1a09",
".git/objects/51/a18bca5fb2a0e6cfde7aaf14ad1db3d1f2af1c": "76725854fe7b27b807d03a3c073199cc",
".git/objects/51/03e757c71f2abfd2269054a790f775ec61ffa4": "d437b77e41df8fcc0c0e99f143adc093",
".git/objects/3d/867211150b05b7e2ef5666cffdb8310f25e167": "41419484d03bf629f43897f079b46869",
".git/objects/3d/1fdc125376caa0ba6f957f033438dc278a4c3d": "ce16a23934653ac0da2984f0d9ec899c",
".git/objects/3d/300c58c5dbd0b15eb51f0db59af86beaf50db3": "5a3ae398ad69e52e43c0c8cf3ff7082a",
".git/objects/0b/9fcf3d6c6058acc662279d9d22099086a0c78a": "0f20d8b31472ed851f3506e98bb44282",
".git/objects/93/62ccaef78b19c6cd6ef12d6a67e5bc2b39e659": "365fb85d4ff0c3e8743c9a2e2096d2eb",
".git/objects/93/b363f37b4951e6c5b9e1932ed169c9928b1e90": "c8d74fb3083c0dc39be8cff78a1d4dd5",
".git/objects/94/d78fc0ea6170de6deffbf1b509f43a2746545b": "36ffe2bad5cb9059f0a308c980ead319",
".git/objects/05/4f78c315b1df7c1db12614f404675556bc15b9": "b906fa4bffdcaff1d7a6e0edbdd3ae91",
".git/objects/9c/5c93b0d8ff30e3a39d00540a983b3da0ccca25": "b023935644cb9709e5d37fb3884a2829",
".git/objects/9c/f04d065c51a3340316f5fff05757c26d87ff59": "6ac25a5c3f0ab66864eb5a2bea36dd6d",
".git/objects/d9/5b1d3499b3b3d3989fa2a461151ba2abd92a07": "a072a09ac2efe43c8d49b7356317e52e",
".git/objects/ac/a8b8e518c4ee79420e9096ca116e11aed50445": "24f973d492ea63bb5aa1341653584676",
".git/objects/ad/ced61befd6b9d30829511317b07b72e66918a1": "37e7fcca73f0b6930673b256fac467ae",
".git/objects/d0/d9c8e6ae7a60da6c44ae6a2ef11e19488fcb20": "1e6f70acc1820c9acc0e18c4f6559b88",
".git/objects/df/6cb2a5cba72a9243ee4b5846f80d77c62464c5": "1a5a3e8e1d580762483608c5554dc00f",
".git/objects/b4/148fe5a8260f652098438b6dd5cbc98c04af8c": "241182960899970f510afad2aea2d814",
".git/objects/bd/930e85533efd2f7c06924bfcce14c653ecd038": "b9ec9499520356dc8ec62ff1dd57c65d",
".git/objects/d1/9e81eecfd64ad11d98d8d3ce1573f5d161ac3b": "4d0493c351bba0cbcfb8b385f75d41b3",
".git/objects/ab/196b9a6e02862e0a1bdf8dbec036cc0d109b6c": "d57c610b6a2ead0e08be149456cc3f33",
".git/objects/f3/3e0726c3581f96c51f862cf61120af36599a32": "afcaefd94c5f13d3da610e0defa27e50",
".git/objects/c0/4136e506a183684e0d4942068f77838914cd8f": "7f07fbb71a70c8889c34d3493c3f9b32",
".git/objects/c0/9b81ecc86becd435cd30bd92256114285e7ac7": "846bf7a645c5a8d7a433eef4568469ab",
".git/objects/c9/6721cf0dd768a950199f53f447904b706529a6": "af8c1da792038b579d4899820eedf0cd",
".git/objects/fd/05cfbc927a4fedcbe4d6d4b62e2c1ed8918f26": "5675c69555d005a1a244cc8ba90a402c",
".git/objects/fd/21b9150f812eb3a4198c4379f0e8225cd24f69": "d39b85caf60fb5f61aef642836817b7c",
".git/objects/fd/2b025646b0dde1e37de5528d7dca3909e729d0": "f4f34c54bddb818ec975b28afce48b57",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/e3/f78fc583453cec3743133a102a3925788b0fe2": "1616279bc89a57144042c9c0054cf4a6",
".git/objects/ca/1cba8f602dd879cb0a4de6f6a1c01cfbe0b8a0": "a2d010b9528f24738b1b5253397d4ee7",
".git/objects/fe/137de56ce794bdd998ac332a62990a17326be6": "96268fa80b3a3c9575a109102010e06c",
".git/objects/fe/d0e7884e784b0eee96d46989a8e83bc56afc62": "7c74d6046f785d9497e237e9776cc703",
".git/objects/c8/3af99da428c63c1f82efdcd11c8d5297bddb04": "144ef6d9a8ff9a753d6e3b9573d5242f",
".git/objects/c1/f3954650ab7cb9af5a341cffb4260e2d4d53a4": "8237782c548f276968a6d1d63df72206",
".git/objects/ec/fb0ca169aed241c1b65132275903d53c389412": "84e49ef6655057a54bcb125b99719b55",
".git/objects/ec/3450e012c58dd64ba6c8e425a0e6b5dc1b0387": "bd37fb181f1a0493c1ba98d4eca2b075",
".git/objects/20/5bb5db271c6d8de8399864c7bb9b917f638893": "c993b22f115d7f3ae6d5b7b212806539",
".git/objects/27/aa4e2524efc448c7ca9d4e33b7b4ef1ef1f230": "452404fbaecd3b82321c6fa59ec15bed",
".git/objects/7d/b55f03e892aa35d199460a496c4c530417491c": "863919115f1c4de2643b60ff8a5d660b",
".git/objects/7c/3463b788d022128d17b29072564326f1fd8819": "37fee507a59e935fc85169a822943ba2",
".git/objects/1a/454ff9b93500ab52620b4e1384e1b7ffc6ceea": "8a965082fc0a59546e32af91a81e6648",
".git/objects/17/19885fd11cf52e39b8fe0ad4a7e562a70bab3e": "eecc1439b20d6647c7da17ebf6cfde76",
".git/objects/7b/6b145b250e1486890eb9f28bcaa660a35c1c1c": "5c53c4923c3bc427bbdce2b75d7ca85c",
".git/objects/8a/d189a8aff7e488ad27d02624a6936c96beb229": "e4ffdd3db82f0ae23c2e32c0de87bc10",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/7e/1cb50fe20d8784cf89e5faade6022eebf9cead": "655053edf5d85985096bfc80643101c7",
".git/objects/4c/6be055d3932bb297005bbc9e517e52b6dd7986": "f9bd124db34da5df6891ebad26cecd09",
".git/objects/4c/1c9bc0def6dfeffce4d8adaaa44286796d2dad": "30609ab711c750070a33536aad445f77",
".git/objects/26/1d63eaa4fd3db1f41f03048068c4870977244f": "96bc98b198ba3e24e9d726e4f846cfad",
".git/objects/4d/2ee59615c08dadccdc94b679062564462f352a": "d43d1792050802a6c1e04c967949bca2",
".git/objects/81/60f26af07638965d8df2dc09daa1b31a2ddc1b": "293ceb85430ec000da0da9d73b534e30",
".git/objects/86/03d0a3d2a91580f77171968c7d13e73fd1482a": "dc750bd17c929d834d260dd7dc0293e7",
".git/objects/72/cba7699a9c3fccd71fcdb8cfb5b3bd5f9f4a14": "cbc09b6cf17e095f955c64b340416707",
".git/objects/2f/a9f901435fa71eb355b8653f80a705605ef010": "e9e6bf41edf84243b6800aadd07421e9",
".git/objects/2f/ce39b9ddf39b62daa760b27a2e52a6adc06054": "6a435b8c92fdbadd114492067b586c8a",
".git/objects/43/8f40a83e90cf3d385009c136630e214fef0f3f": "5dcc7b09618df2906f50c2b1aeed3d97",
".git/objects/43/0861272c08a9dbd8cf661caa9e1fafdbcd0ccd": "4e37c405aee05357d7b190dfc3a4a158",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/38/1370be856444334e19ffdd3461f18ae67bb227": "3d0f9ddfb6c22ab7844e7e09383b68bb",
".git/objects/5c/45f5de5981587e47a605f4c0f79f87435dc317": "27327e84814e580d665fa9b8ef1491d6",
".git/objects/5d/fb25dfd9b861cb64724cc4c75784ca8e52cd93": "ed8ba530337b4c4433d0ab17f41eb5a8",
".git/objects/31/0a7c1fe11ea11dabf34fecb24693ca47ba10f5": "1ab58c3fcdf9aa0d5847b66750457a9f",
".git/objects/31/7b84ba1121945c33909c5d35b75ec271c599ec": "290ac9241095ed906ede36a206f27567",
".git/objects/62/db056730ec7bb7bf81bffc9b278bd4cc2b7950": "55c3bc935675b6a8278141a494b2c994",
".git/objects/3a/8cda5335b4b2a108123194b84df133bac91b23": "1636ee51263ed072c69e4e3b8d14f339",
".git/objects/54/3c9f4de62a4b9c5fe711901b60463520887af6": "1a84dda584274d4f2d63d26f19d42afd",
".git/objects/53/fac6306535d7b14dc338d36e9dfffab3a155ab": "6efcc6085c2c6d935eae1b68de26b818",
".git/objects/3f/32f1ceac186425182bf818036a01f213d9bc64": "9224f32c8e89fb5f52456685f44ed807",
".git/objects/3f/af7cf152c9f5bb90713cbbd2ec398553a21085": "7219c5e32311250faae4168a6f07cd4d",
".git/objects/3f/98cdec222e0471d8e52158aff0823d6e97a395": "83e9dec15e73a79e1b0ad43158559ab3",
".git/objects/08/27c17254fd3959af211aaf91a82d3b9a804c2f": "360dc8df65dabbf4e7f858711c46cc09",
".git/objects/01/2d693e20bf77481e834b010bbf10752869db59": "13f9814394b0cd5bf04b7bee4b7e05e6",
".git/objects/06/886bddf673a52c4704fa48c7095da519793e5f": "4d83147d52d5cd2e1b6a8066ad7f5cef",
".git/objects/06/ac6e0b70d69d238c84353fe5690100fe2f4da7": "908207d7ee04896ed7c594e5457c5a32",
".git/objects/39/6aa777528fb3c18f94008393c07249fc1e9998": "16252c8117ceb2b8488d168e5056c6bb",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/b1/02894cb67e8e8dfda559f062fd2b1df04ab722": "5d0a6f7e07fdc456ad5a76d83e986a75",
".git/objects/b6/640e57743764d258e513b59c56fa6e310ed39f": "02b908dd8dc9d1ae2c604cd2c8d08266",
".git/objects/d5/12ffbe53dcdaa821f98a2cab9156943a17f9c3": "71b5320362dc05deff2b3bd162c01ea9",
".git/objects/d2/460d18b9f41505bc5febe9a2907d59f2038544": "6228ee6a7900ccac3924fac15ec52e8c",
".git/objects/aa/5cf7fe0712fcf23ed93b4e64837dab7f3e7803": "3fa9b479ffaa19c27c18e40246713777",
".git/objects/af/2f7043143b12fba5fbd8a6749016acdeca737b": "b321017870948e4490b16c48a0073606",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/de/1bb5d889b4502a0ee5bd35983d77a4bf82a30a": "021eeea6471b472ba584bc09dcec81df",
".git/objects/de/a16ad46e13985a5e162ca14ef8e44ced4ef53f": "41003ead6f623ae17b20cd1bbfa753a8",
".git/objects/a6/d473892195b2a1ceb07636e3b4104de7bece28": "188f4b9abadf9c4b720d9bb8f15d8cfb",
".git/objects/b9/5a0503bbc9a131213f863b542dddf0c5f8793c": "6a29e3cec8bd18b94d8d78c37337cfe5",
".git/objects/b9/3e39bd49dfaf9e225bb598cd9644f833badd9a": "666b0d595ebbcc37f0c7b61220c18864",
".git/objects/ef/d44c9041917748371799f931d4db1cc5948ab8": "aeaa8c79aaedcaf73752d3580e2e48cd",
".git/objects/c4/9ac35061e1d3dc1b14420d92bb6c5423d58db9": "e837e942dee0a02559d39564e30f5375",
".git/objects/c4/058180dab2d73ffddf78c8669becbad227f387": "bbaf81bebeaad65b0482d76cd0b8bdc0",
".git/objects/cd/4699fae26bf825e959154d98ff96db67040ee4": "65bf9832142a14a28d4ea7e7086b5172",
".git/objects/cd/663883b0b7d862011b98895f6b5542aa2a8846": "f68842eecf5b3af3661c2c3a77429872",
".git/objects/cc/2bf49b09b94860cfed53cfc8a435c61d37112a": "cc1013b90908a5c125273c5b2366dc27",
".git/objects/e6/f269a394011b0fe854801bad0dcec98d3e2359": "054ba5b529d77a159265a83d54419f55",
".git/objects/e6/eb8f689cbc9febb5a913856382d297dae0d383": "466fce65fb82283da16cdd7c93059ff3",
".git/objects/f0/eca047893fb057e8202e855ee898cdd156ddf1": "c6b1d2b5a5074773762def61c1f625a1",
".git/objects/e8/c6f990c0d3f9690ef872ea653d60b4aaa19df0": "c52db0caa93b62245eaf2bfdded68329",
".git/objects/fa/ccf8f08472f68385c790e27b4edaa8b980e101": "f5c68e986e6e6aedd4cb761e6d20d9e5",
".git/objects/fa/d4bacaef53f31cda20e0f06172cb20e0028a76": "9c667ad4b6dd99b671e8b7348fcd9a15",
".git/objects/ff/3820fc707fac116138d7153753f256df5d4e94": "59d8bba71b85a7aea89b40bacc9820df",
".git/objects/c5/67edc5316ae6e686cdf7ad7380888e958d2af6": "707ff57a91743576558db9e88dbb159b",
".git/objects/f6/e6c75d6f1151eeb165a90f04b4d99effa41e83": "95ea83d65d44e4c524c6d51286406ac8",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/f1/b7eca3247451b310a339c8d73efb0669294419": "9e5dac4c789251906af985125eb36ac6",
".git/objects/f1/0256f7b40d8065e4782a6a9d9ee82f5f97600e": "a3a41ec42dc0b3516483e34992aafd14",
".git/objects/e0/7797437d096064bd90c373800dcb0f335c14b0": "16f9b9defb16491f8c733b09b022688c",
".git/objects/e0/1e0438e037f0190dedd2a0101a698744cf9119": "003e1818d6a110e8b10dea07d644e2d1",
".git/objects/46/f0b4991f0870c0a87895206893c01b95844e2f": "76fa143d22259c4d034bcf271b651f6a",
".git/objects/2c/69f8cf4ae88cb1a73525bf8e514824bb7f5f47": "a8a348db8b0a3b318c0ab6b0cb525f1f",
".git/objects/2c/517431c69e360d7d432ef4d09f1b4dae68a56d": "7c7e26956c58784050551eaffb12433c",
".git/objects/2d/ebdbcc0067e7fcc0979fad099b6dbb9da6bb97": "6b2a6a810355d394f022a85b2a6d7455",
".git/objects/2d/791b8925ecf09c10ee3eff5422c92eb0424eb4": "d090b04ffe983a2df3ed2aca7a413321",
".git/objects/41/821bd9e4c7e11e30a5b214021c00974b586205": "cef74c25eeac2088495ee50ff70acb8a",
".git/objects/48/1c69ae50101dd96d5d8fb17824ad380dbc5075": "e5a6403789043e7b806c26a5616af4d0",
".git/objects/1e/307bd9f0864de794f2def8ed0e64d3e71c5eb0": "b8abfb073626f3ef1efc116689016e47",
".git/objects/24/b6868ffbbf69d5866fa21d9e7b74afbac5a24b": "38d71225ada69ba83db92d360f7e079f",
".git/objects/23/b8c94be3ad097236474a0cf981807de68f4774": "a7304f9b6c1c83f933e0346460bad464",
".git/objects/4f/d97d1deca5a484ed71edcbdae9745923a5c32b": "cbfcf809b6315ae3394ffe62e72f3c7b",
".git/objects/15/e7997b445a5aa44f4a709b5d294d9dd1edb88d": "260df102d416685785352101ce18fe81",
".git/objects/12/6af7d442c303e54de4fc8d56c1894b423d6553": "846ca3abffb29ebffcace2973c4426eb",
".git/objects/8c/1f0a12843e859f2007bbbed03bf736db46fbd5": "aa8df2467b7a5d1d8929fcbaf8c61858",
".git/objects/85/c75871329f4b67b6e322d76140ae60541485f2": "88bcbbc743eaa22ecaa13ccdfc9b5831",
".git/objects/85/f7c2ef6d64c98512203a4be71e83b9af226180": "0b023811eb7a9b36460371954d7bb8ad",
".git/objects/85/63aed2175379d2e75ec05ec0373a302730b6ad": "997f96db42b2dde7c208b10d023a5a8e",
".git/objects/76/1a53c99cbb48f15131c10acfbb276abfa22418": "e97a5da2f6d38b949648b427e23af882",
".git/objects/1c/d989da8559635b0f7600526adc9c88bb99a441": "05234f4f498ff810155055e229ffab8e",
".git/objects/82/05839c76641d5ada809b48b4269a42fa53ba7c": "e35219fe2ab67ea45c765c66e17d11cb",
".git/objects/40/e2816811b548da3d4d6fcda0a73a90acf5c0d2": "6edc1258b35dc5a6d505a5122ec9130b",
".git/objects/40/f528f97b0f876551d04c30f18992ee8c22e1ad": "0fd7c89717649ad43ac4063ff1ec5c42",
".git/objects/47/300ba3160574f01ad6943343d1f34b9288782d": "a3f3044ee071bcbd026f2edece480a5f",
".git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "29904665f437f47130df8721d1825e15",
".git/logs/refs/heads/main": "ca11618df0c5c7fea52f427242684efe",
".git/logs/refs/remotes/origin/HEAD": "0d91adab3f78c4a15b799fa71513aae5",
".git/logs/refs/remotes/origin/main": "4ceac79cc2ca6064533090a66de481cb",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/refs/heads/main": "eeccada87f4601e479d032c44ce9997e",
".git/refs/remotes/origin/HEAD": "98b16e0b650190870f1b40bc8f4aec4e",
".git/refs/remotes/origin/main": "eeccada87f4601e479d032c44ce9997e",
".git/index": "2be018d03442f88fa72d74fdf2536b3c",
".git/COMMIT_EDITMSG": "63607fa004df7074334d86110ab9945a",
".git/FETCH_HEAD": "c8b8978e1c9ce4ad5f608b29b5dd20d1",
"assets/NOTICES": "58e9f69790cf35e2c43bd48cb69aa57d",
"assets/FontManifest.json": "5f79ac56d64767f6b6355e2d8ac63f39",
"assets/AssetManifest.bin.json": "e6644b0490c331121182113df08ec195",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/AssetManifest.bin": "36ace8b2bfaedeae394fec39d75f142d",
"assets/fonts/MaterialIcons-Regular.otf": "f56c24b0922b7dc4cb0fd34f4359c84c",
"assets/assets/question_info/public-parks.toml": "442afc34eecfa0c4a2831887da8b7ae6",
"assets/assets/question_info/comfort-level.toml": "c3b998e926aa14a45d073e91b3839d77",
"assets/assets/question_info/bus-stops-google-earth.toml": "d306c0861dd2d2df2e4a3e4299bf32f4",
"assets/assets/question_info/walkability.toml": "19a177e0688a1adf0bbc5bf64dfa4c9c",
"assets/assets/question_info/maps-mini.toml": "ebadafc50b7693f04832b617ba88ce14",
"assets/assets/question_info/bike-lanes-rtc.toml": "0b9ad2b4dcdf5aa6ae00b60a9597d857",
"assets/assets/question_info/schools-las-vegas.toml": "e4fbd9abfbd0f7d6050f647f102d27c3",
"assets/assets/question_info/land-use-diversity.toml": "02f6b3560cf77c19d6b04182cfd5f629",
"assets/assets/question_info/usage.csv": "687348e21ecad14356d98efcdbb6c8f5",
"assets/assets/question_info/biking-rate.toml": "4d0d831bf91f00718320e3873dfc2e7a",
"assets/assets/question_info/bus-stops-rtc.toml": "8d365fbd31f3f2b2427df7f6b8045182",
"assets/assets/question_info/walking-rate.toml": "cf0db20d6cc9912d51b90c8a462ce413",
"assets/assets/question_info/underserved.toml": "b1cd4af307225295ff02967c2201513c",
"assets/assets/question_info/bus-stops-las-vegas.toml": "0ab7cb2376d33cda30ddc263ee4d4f79",
"assets/assets/question_info/public-parks-las-vegas.toml": "afe286eeee760a7e904172c6c9ac6cf8",
"assets/assets/question_info/pedestrian-crash.toml": "0a2c531fd7da0d64175ef6f14f6bc255",
"assets/assets/question_info/bike-lanes-henderson.toml": "c8ff791559482295ceeb1fe465233a8b",
"assets/assets/question_info/schools.toml": "b9371b7cb0b0783decaa39c9f88bedf2",
"assets/assets/question_info/bicycle-crash.toml": "5dc99ddd7dcd910846819116e5a3bb7e",
"assets/assets/question_info/hu-jpa.toml": "4c4e5ef7c6f637abeab3d9cf1102afe3",
"assets/assets/assessment_info/henderson.toml": "8a82561993352a498e47331bcb028048",
"assets/assets/assessment_info/mesquite.toml": "c7f5fa6b7aea9deb9b90c8d04ca5aceb",
"assets/assets/assessment_info/boulder.toml": "348fd2bb4156cd6d1bfb1d94956fb59d",
"assets/assets/assessment_info/north-las-vegas.toml": "1cf6de8fd9e3e95c65a42b5ca4c16286",
"assets/assets/assessment_info/clark-county.toml": "04aa094eb20ebea6c57e365aa2f79ec8",
"assets/assets/assessment_info/las-vegas.toml": "da501d1cca571c71aa4a161559a49114",
"assets/assets/recommendations_info/nv-recommendations-info.toml": "a963d8c160e71faf03cbded3052508bb",
"assets/assets/fonts/arial-unicode-ms.ttf": "91f4475d007aa64dd9a0e79927f3d095",
"assets/assets/data/nevada_adi_data.json": "6040e50053cc1f9122432b5bf6ebc5ad",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01"};
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
