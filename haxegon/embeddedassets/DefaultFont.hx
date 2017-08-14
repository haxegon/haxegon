package haxegon.embeddedassets;

import openfl.display.BitmapData;
import openfl.utils.ByteArray;

class DefaultFont {
	private static var fontbytearray:Array<UInt>;
	
	private static var XML_DATA:String = '
		<font>
			<info face="default" size="8" bold="0" italic="0" charset="" unicode="1" stretchH="100" smooth="0" aa="1" padding="0,0,0,0" spacing="1,1" outline="0"/>
			<common lineHeight="8" base="7" scaleW="256" scaleH="22" pages="1" packed="0" alphaChnl="1" redChnl="0" greenChnl="0" blueChnl="0"/>
			<pages>
				<page id="0" file="default_0.png" />
			</pages>
			<chars count="96">
				<char id="32" x="85" y="16" width="3" height="1" xoffset="-1" yoffset="7" xadvance="5" page="0" chnl="15" />
				<char id="33" x="127" y="8" width="2" height="7" xoffset="0" yoffset="0" xadvance="3" page="0" chnl="15" />
				<char id="34" x="44" y="16" width="4" height="3" xoffset="0" yoffset="0" xadvance="5" page="0" chnl="15" />
				<char id="35" x="54" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="36" x="250" y="0" width="5" height="7" xoffset="0" yoffset="0" xadvance="6" page="0" chnl="15" />
				<char id="37" x="162" y="8" width="6" height="6" xoffset="0" yoffset="1" xadvance="7" page="0" chnl="15" />
				<char id="38" x="75" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="39" x="49" y="16" width="3" height="3" xoffset="0" yoffset="0" xadvance="4" page="0" chnl="15" />
				<char id="40" x="123" y="8" width="3" height="7" xoffset="0" yoffset="0" xadvance="4" page="0" chnl="15" />
				<char id="41" x="119" y="8" width="3" height="7" xoffset="0" yoffset="0" xadvance="4" page="0" chnl="15" />
				<char id="42" x="63" y="8" width="5" height="7" xoffset="0" yoffset="0" xadvance="6" page="0" chnl="15" />
				<char id="43" x="14" y="16" width="5" height="5" xoffset="0" yoffset="1" xadvance="6" page="0" chnl="15" />
				<char id="44" x="53" y="16" width="3" height="3" xoffset="0" yoffset="5" xadvance="4" page="0" chnl="15" />
				<char id="45" x="78" y="16" width="6" height="1" xoffset="0" yoffset="3" xadvance="7" page="0" chnl="15" />
				<char id="46" x="66" y="16" width="2" height="2" xoffset="0" yoffset="5" xadvance="3" page="0" chnl="15" />
				<char id="47" x="32" y="0" width="7" height="7" xoffset="0" yoffset="0" xadvance="8" page="0" chnl="15" />
				<char id="48" x="89" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="49" x="133" y="8" width="2" height="7" xoffset="0" yoffset="0" xadvance="3" page="0" chnl="15" />
				<char id="50" x="145" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="51" x="152" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="52" x="159" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="53" x="166" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="54" x="173" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="55" x="180" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="56" x="40" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="57" x="187" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="58" x="252" y="8" width="2" height="5" xoffset="0" yoffset="2" xadvance="3" page="0" chnl="15" />
				<char id="59" x="183" y="8" width="3" height="6" xoffset="0" yoffset="2" xadvance="4" page="0" chnl="15" />
				<char id="60" x="114" y="8" width="4" height="7" xoffset="0" yoffset="0" xadvance="5" page="0" chnl="15" />
				<char id="61" x="32" y="16" width="5" height="3" xoffset="0" yoffset="2" xadvance="6" page="0" chnl="15" />
				<char id="62" x="104" y="8" width="4" height="7" xoffset="0" yoffset="0" xadvance="5" page="0" chnl="15" />
				<char id="63" x="215" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="64" x="222" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="65" x="229" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="66" x="236" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="67" x="243" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="68" x="117" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="69" x="0" y="9" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="70" x="7" y="9" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="71" x="14" y="8" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="72" x="21" y="8" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="73" x="136" y="8" width="1" height="7" xoffset="0" yoffset="0" xadvance="2" page="0" chnl="15" />
				<char id="74" x="69" y="8" width="5" height="7" xoffset="0" yoffset="0" xadvance="6" page="0" chnl="15" />
				<char id="75" x="28" y="8" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="76" x="35" y="8" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="77" x="42" y="8" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="78" x="49" y="8" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="79" x="68" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="80" x="47" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="81" x="208" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="82" x="201" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="83" x="194" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="84" x="16" y="0" width="7" height="7" xoffset="0" yoffset="0" xadvance="8" page="0" chnl="15" />
				<char id="85" x="131" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="86" x="124" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="87" x="110" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="88" x="82" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="89" x="8" y="0" width="7" height="7" xoffset="0" yoffset="0" xadvance="8" page="0" chnl="15" />
				<char id="90" x="56" y="8" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="91" x="109" y="8" width="4" height="7" xoffset="0" yoffset="0" xadvance="5" page="0" chnl="15" />
				<char id="92" x="24" y="0" width="7" height="7" xoffset="0" yoffset="0" xadvance="8" page="0" chnl="15" />
				<char id="93" x="99" y="8" width="4" height="7" xoffset="0" yoffset="0" xadvance="5" page="0" chnl="15" />
				<char id="94" x="38" y="16" width="5" height="3" xoffset="0" yoffset="0" xadvance="6" page="0" chnl="15" />
				<char id="95" x="69" y="16" width="8" height="1" xoffset="0" yoffset="7" xadvance="9" page="0" chnl="15" />
				<char id="96" x="57" y="16" width="3" height="3" xoffset="0" yoffset="0" xadvance="4" page="0" chnl="15" />
				<char id="97" x="245" y="8" width="6" height="5" xoffset="0" yoffset="2" xadvance="7" page="0" chnl="15" />
				<char id="98" x="61" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="99" x="26" y="16" width="5" height="5" xoffset="0" yoffset="2" xadvance="6" page="0" chnl="15" />
				<char id="100" x="96" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="101" x="203" y="8" width="6" height="5" xoffset="0" yoffset="2" xadvance="7" page="0" chnl="15" />
				<char id="102" x="103" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="103" x="148" y="8" width="6" height="6" xoffset="0" yoffset="2" xadvance="7" page="0" chnl="15" />
				<char id="104" x="138" y="0" width="6" height="7" xoffset="0" yoffset="0" xadvance="7" page="0" chnl="15" />
				<char id="105" x="138" y="8" width="1" height="7" xoffset="0" yoffset="0" xadvance="2" page="0" chnl="15" />
				<char id="106" x="0" y="0" width="5" height="8" xoffset="0" yoffset="0" xadvance="6" page="0" chnl="15" />
				<char id="107" x="75" y="8" width="5" height="7" xoffset="0" yoffset="0" xadvance="6" page="0" chnl="15" />
				<char id="108" x="130" y="8" width="2" height="7" xoffset="0" yoffset="0" xadvance="3" page="0" chnl="15" />
				<char id="109" x="187" y="8" width="7" height="5" xoffset="0" yoffset="2" xadvance="8" page="0" chnl="15" />
				<char id="110" x="20" y="16" width="5" height="5" xoffset="0" yoffset="2" xadvance="6" page="0" chnl="15" />
				<char id="111" x="210" y="8" width="6" height="5" xoffset="0" yoffset="2" xadvance="7" page="0" chnl="15" />
				<char id="112" x="169" y="8" width="6" height="6" xoffset="0" yoffset="2" xadvance="7" page="0" chnl="15" />
				<char id="113" x="176" y="8" width="6" height="6" xoffset="0" yoffset="2" xadvance="7" page="0" chnl="15" />
				<char id="114" x="217" y="8" width="6" height="5" xoffset="0" yoffset="2" xadvance="7" page="0" chnl="15" />
				<char id="115" x="7" y="17" width="6" height="5" xoffset="0" yoffset="2" xadvance="7" page="0" chnl="15" />
				<char id="116" x="81" y="8" width="5" height="7" xoffset="0" yoffset="0" xadvance="6" page="0" chnl="15" />
				<char id="117" x="224" y="8" width="6" height="5" xoffset="0" yoffset="2" xadvance="7" page="0" chnl="15" />
				<char id="118" x="231" y="8" width="6" height="5" xoffset="0" yoffset="2" xadvance="7" page="0" chnl="15" />
				<char id="119" x="195" y="8" width="7" height="5" xoffset="0" yoffset="2" xadvance="8" page="0" chnl="15" />
				<char id="120" x="238" y="8" width="6" height="5" xoffset="0" yoffset="2" xadvance="7" page="0" chnl="15" />
				<char id="121" x="155" y="8" width="6" height="6" xoffset="0" yoffset="2" xadvance="7" page="0" chnl="15" />
				<char id="122" x="0" y="17" width="6" height="5" xoffset="0" yoffset="2" xadvance="7" page="0" chnl="15" />
				<char id="123" x="87" y="8" width="5" height="7" xoffset="0" yoffset="0" xadvance="6" page="0" chnl="15" />
				<char id="124" x="6" y="0" width="1" height="8" xoffset="0" yoffset="0" xadvance="2" page="0" chnl="15" />
				<char id="125" x="93" y="8" width="5" height="7" xoffset="0" yoffset="0" xadvance="6" page="0" chnl="15" />
				<char id="126" x="61" y="16" width="4" height="2" xoffset="0" yoffset="0" xadvance="5" page="0" chnl="15" />
				<char id="127" x="140" y="8" width="7" height="6" xoffset="0" yoffset="1" xadvance="8" page="0" chnl="15" />
			</chars>
		</font>
	';
	
  public static var bitmapdata(get, never):BitmapData;
	private static var _actualbitmapdata:BitmapData = null;
	
	static function get_bitmapdata():BitmapData {
	  if (_actualbitmapdata == null) {
			fontbytearray = 
				[0x78daed9b, 0xdd52ec40, 0x884f7fd, 0x5f5acfa5, 0x5665a0bf, 0x6e2c92e, 0xdc6819c3, 0x2433fc34, 0xd79bd7e, 
				0xcbd73fb9, 0xfaf90afe, 0xef24d1fd, 0x99fcbcef, 0x4aef69ed, 0x48c7d5ef, 0xa7b5239d, 0x57f7677f, 0x8b74aaba, 
				0xb27788ce, 0x44bd8f5c, 0xa37b96bd, 0x7b76b691, 0x5ef53ee7, 0x39c973d0, 0x7757ae45, 0xfa9cf588, 0xff65feaf, 
				0xe8a631a0, 0xc35e5dff, 0x57d78b62, 0xd7dceec, 0xdad5ba9d, 0x7e5cf5ff, 0x8e7757e2, 0x946b6bff, 0xd39ea936, 
				0x446c97ac, 0x97c561d7, 0xd61d1ba1, 0xb64ff73e, 0xc224d5fc, 0xe8c69e93, 0xadab38e6, 0xafedbc82, 0x61b23356, 
				0xf784e493, 0x8aef4cc6, 0xf628a64f, 0xc668f5dc, 0x14ac457d, 0xbc12d3a7, 0xf13f8da1, 0x190e8e62, 0x52258655, 
				0x7556f645, 0x8d4b04e7, 0x3a393f3b, 0x77e5f948, 0x6de0e60b, 0x5df9cce, 0xb12b77b9, 0x3eecd40e, 0x4a5ca6d8, 
				0xa112ef08, 0x2741af65, 0x98208b19, 0x649f55bf, 0x9cf6ff4a, 0x5ca418ad, 0x6a9b2ede, 0xac60e128, 0x7792bd9b, 
				0xe26828af, 0x37e1fff4, 0xacaa9c54, 0xa79dd3dc, 0xd5512392, 0x7c427576, 0xd65acef9, 0x4df13e4e, 0x2eea3a77, 
				0xb736b9a3, 0xb65330c3, 0x1dfeefc4, 0x2c17ef64, 0xf65fe173, 0xbbb81787, 0xb375eb06, 0x82d32bfd, 0x6a7f7d1, 
				0xcdab530c, 0xec62fc0c, 0x5f129c5a, 0x3d5bd796, 0x2a1ccbca, 0xcacae7c9, 0x9d3de689, 0x3e80c33b, 0x55f9cb8c, 
				0xb537381, 0x12e3d5d9, 0xd959fea, 0xe06b5d7e, 0xb18ad74e, 0x759292f3, 0x3ae60748, 0x9eedea2d, 0x46584ce5, 
				0xc9263934, 0xc2ff9273, 0xa4bc4e85, 0x13716bdd, 0x4a2decce, 0xea8bc93, 0x32bfe5f4, 0x2a89ff4f, 0xf09299fe, 
				0xa27e6c6, 0xb689f916, 0x35e63b39, 0xb793b373, 0x7d56f15f, 0x955ba9f0, 0xce5d3d19, 0xeac76e0f, 0x45c98d4a, 
				0xfea73954, 0x5ddfed7f, 0x54632a89, 0xf5df9b0, 0x93e7a47d, 0xce6e1fa7, 0xb8c1994d, 0x54fb5dc4, 0xd6e81ed1, 
				0xbeaf3a27, 0xd339df33, 0xedff0463, 0x675c20ed, 0x75a8b8bb, 0x23ff137c, 0x30d91fa9, 0xce0b2af9, 0xdfadabaa, 
				0x3869aa0f, 0x48310ecd, 0xff1d33d1, 0x4fcdffe4, 0x9b08278f, 0x647e4b7a, 0x4bd4ffd5, 0xbad2991f, 0x7278b42c, 
				0x7791faff, 0xefc3f5d, 0xff4f718a, 0x997fab75, 0xf1d3ea7f, 0x65cd68fe, 0xb7fb1b9b, 0x93cdbbfe, 0x4f66923e, 
				0x99c377ae, 0x4df1ff13, 0x7ca33b5f, 0xafce4abc, 0x3ff4fea, 0xff95f7f2, 0xffee6f77, 0x5756563e, 0x133f50ec, 
				0x477333e1, 0x439cefda, 0x328cebce, 0xaeafac3c, 0x2dff57fd, 0xb38a1f29, 0x6fe3725b, 0x5b2baeac, 0x703e4ea9, 
				0x19c81c09, 0xd553ed2b, 0xafacace4, 0x3e437af6, 0x9df97f65, 0x65e5fe1a, 0x9ed6fba4, 0x5edf5a79, 0x65e519f5, 
				0xfff25b2b, 0x2bef2ddf, 0xa3200119
			];
			_actualbitmapdata = new BitmapData(256, 22);
			var bmpBytes:ByteArray = new ByteArray();
      bmpBytes.endian = flash.utils.Endian.BIG_ENDIAN;
			
			for (i in 0 ... fontbytearray.length)	bmpBytes.writeUnsignedInt(fontbytearray[i]);
			
			bmpBytes.uncompress();
			_actualbitmapdata.setPixels(new openfl.geom.Rectangle(0, 0, 256, 22), bmpBytes);
			bmpBytes.clear();
		}
		
		return _actualbitmapdata;	
	}

  public static var xmlstring(get, never):String;
  private static function get_xmlstring():String { return XML_DATA; }
}