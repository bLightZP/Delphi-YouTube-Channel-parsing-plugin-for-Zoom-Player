unit ISO_3166_1_alpha_2_unit;

interface

// Source:
// https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

Const
  ISO_3166_1_alpha_2_Count = 249;
  ISO_3166_1_alpha_2       : Array[0..ISO_3166_1_alpha_2_Count-1] of String[2] =
  ('AD',   // Andorra
   'AE',   // United Arab Emirates
   'AF',   // Afghanistan
   'AG',   // Antigua and Barbuda
   'AI',   // Anguilla
   'AL',   // Albania
   'AM',   // Armenia
   'AO',   // Angola
   'AQ',   // Antarctica
   'AR',   // Argentina
   'AS',   // American Samoa
   'AT',   // Austria
   'AU',   // Australia
   'AW',   // Aruba
   'AX',   // Aland Islands
   'AZ',   // Azerbaijan
   'BA',   // Bosnia and Herzegovina
   'BB',   // Barbados
   'BD',   // Bangladesh
   'BE',   // Belgium
   'BF',   // Burkina Faso 	
   'BG',   // Bulgaria 	
   'BH',   // Bahrain 	
   'BI',   // Burundi
   'BJ',   // Benin
   'BL',   // Saint Barthelemy
   'BM',   // Bermuda
   'BN',   // Brunei Darussalam
   'BO',   // Bolivia, Plurinational State of
   'BQ',   // Bonaire, Sint Eustatius and Saba
   'BR',   // Brazil
   'BS',   // Bahamas
   'BT',   // Bhutan
   'BV',   // Bouvet Island
   'BW',   // Botswana
   'BY',   // Belarus
   'BZ',   // Belize 
   'CA',   // Canada
   'CC',   // Cocos (Keeling) Islands
   'CD',   // Congo, the Democratic Republic of
   'CF',   // Central African Republic
   'CG',   // Congo
   'CH',   // Switzerland 	
   'CI',   // Cote d''Ivoire
   'CK',   // Cook Islands
   'CL',   // Chile
   'CM',   // Cameroon
   'CN',   // China
   'CO',   // Colombia
   'CR',   // Costa Rica
   'CU',   // Cuba
   'CV',   // Cabo Verde
   'CW',   // Curacao
   'CX',   // Christmas Island
   'CY',   // Cyprus
   'CZ',   // Czechia
   'DE',   // Germany
   'DJ',   // Djibouti
   'DK',   // Denmark
   'DM',   // Dominica
   'DO',   // Dominican Republic
   'DZ',   // Algeria 
   'EC',   // Ecuador 
   'EE',   // Estonia 
   'EG',   // Egypt
   'EH',   // Western Sahara
   'ER',   // Eritrea       
   'ES',   // Spain
   'ET',   // Ethiopia
   'FI',   // Finland
   'FJ',   // Fiji
   'FK',   // Falkland Islands (Malvinas)
   'FM',   // Micronesia, Federated States of
   'FO',   // Faroe Islands  
   'FR',   // France
   'GA',   // Gabon
   'GB',   // United Kingdom of Great Britain and Northern Ireland
   'GD',   // Grenada
   'GE',   // Georgia
   'GF',   // French Guiana
   'GG',   // Guernsey
   'GH',   // Ghana
   'GI',   // Gibraltar
   'GL',   // Greenland
   'GM',   // Gambia
   'GN',   // Guinea
   'GP',   // Guadeloupe
   'GQ',   // Equatorial Guinea
   'GR',   // Greece
   'GS',   // South Georgia and the South Sandwich Islands
   'GT',   // Guatemala
   'GU',   // Guam
   'GW',   // Guinea-Bissau
   'GY',   // Guyana
   'HK',   // Hong Kong
   'HM',   // Heard Island and McDonald Islands
   'HN',   // Honduras
   'HR',   // Croatia
   'HT',   // Haiti
   'HU',   // Hungary   
   'ID',   // Indonesia 
   'IE',   // Ireland
   'IL',   // Israel
   'IM',   // Isle of Man
   'IN',   // India
   'IO',   // British Indian Ocean Territory
   'IQ',   // Iraq
   'IR',   // Iran, Islamic Republic of
   'IS',   // Iceland 
   'IT',   // Italy 	
   'JE',   // Jersey 	
   'JM',   // Jamaica
   'JO',   // Jordan 	
   'JP',   // Japan 	
   'KE',   // Kenya
   'KG',   // Kyrgyzstan
   'KH',   // Cambodia  
   'KI',   // Kiribati  
   'KM',   // Comoros
   'KN',   // Saint Kitts and Nevis
   'KP',   // Korea, Democratic People''s Republic of
   'KR',   // Korea, Republic of
   'KW',   // Kuwait
   'KY',   // Cayman Islands 	
   'KZ',   // Kazakhstan
   'LA',   // Lao People''s Democratic Republic
   'LB',   // Lebanon        
   'LC',   // Saint Lucia    
   'LI',   // Liechtenstein  
   'LK',   // Sri Lanka      
   'LR',   // Liberia        
   'LS',   // Lesotho        
   'LT',   // Lithuania      
   'LU',   // Luxembourg
   'LV',   // Latvia 	
   'LY',   // Libya 	
   'MA',   // Morocco 
   'MC',   // Monaco
   'MD',   // Moldova, Republic of
   'ME',   // Montenegro
   'MF',   // Saint Martin (French part)
   'MG',   // Madagascar
   'MH',   // Marshall Islands
   'MK',   // Macedonia, the former Yugoslav Republic of
   'ML',   // Mali
   'MM',   // Myanmar  
   'MN',   // Mongolia 
   'MO',   // Macao
   'MP',   // Northern Mariana Islands
   'MQ',   // Martinique
   'MR',   // Mauritania
   'MS',   // Montserrat
   'MT',   // Malta
   'MU',   // Mauritius
   'MV',   // Maldives
   'MW',   // Malawi
   'MX',   // Mexico
   'MY',   // Malaysia
   'MZ',   // Mozambique
   'NA',   // Namibia
   'NC',   // New Caledonia
   'NE',   // Niger
   'NF',   // Norfolk Island
   'NG',   // Nigeria       
   'NI',   // Nicaragua
   'NL',   // Netherlands
   'NO',   // Norway 
   'NP',   // Nepal  
   'NR',   // Nauru  
   'NU',   // Niue
   'NZ',   // New Zealand
   'OM',   // Oman
   'PA',   // Panama 
   'PE',   // Peru
   'PF',   // French Polynesia
   'PG',   // Papua New Guinea
   'PH',   // Philippines    
   'PK',   // Pakistan
   'PL',   // Poland
   'PM',   // Saint Pierre and Miquelon
   'PN',   // Pitcairn     
   'PR',   // Puerto Rico
   'PS',   // Palestine, State of
   'PT',   // Portugal
   'PW',   // Palau 	
   'PY',   // Paraguay
   'QA',   // Qatar 	
   'RE',   // Reunion
   'RO',   // Romania
   'RS',   // Serbia
   'RU',   // Russian Federation
   'RW',   // Rwanda
   'SA',   // Saudi Arabia
   'SB',   // Solomon Islands
   'SC',   // Seychelles
   'SD',   // Sudan  
   'SE',   // Sweden
   'SG',   // Singapore
   'SH',   // Saint Helena, Ascension and Tristan da Cunha
   'SI',   // Slovenia
   'SJ',   // Svalbard and Jan Mayen
   'SK',   // Slovakia
   'SL',   // Sierra Leone
   'SM',   // San Marino
   'SN',   // Senegal
   'SO',   // Somalia
   'SR',   // Suriname
   'SS',   // South Sudan
   'ST',   // Sao Tome and Principe
   'SV',   // El Salvador
   'SX',   // Sint Maarten (Dutch part)
   'SY',   // Syrian Arab Republic
   'SZ',   // Swaziland
   'TC',   // Turks and Caicos Islands
   'TD',   // Chad
   'TF',   // French Southern Territories
   'TG',   // Togo
   'TH',   // Thailand 	
   'TJ',   // Tajikistan 	
   'TK',   // Tokelau 	
   'TL',   // Timor-Leste
   'TM',   // Turkmenistan 	
   'TN',   // Tunisia
   'TO',   // Tonga 	
   'TR',   // Turkey
   'TT',   // Trinidad and Tobago
   'TV',   // Tuvalu
   'TW',   // Taiwan, Province of China
   'TZ',   // Tanzania, United Republic of
   'UA',   // Ukraine
   'UG',   // Uganda
   'UM',   // United States Minor Outlying Islands
   'US',   // United States of America
   'UY',   // Uruguay
   'UZ',   // Uzbekistan
   'VA',   // Holy See
   'VC',   // Saint Vincent and the Grenadines
   'VE',   // Venezuela, Bolivarian Republic of
   'VG',   // Virgin Islands, British
   'VI',   // Virgin Islands, U.S.
   'VN',   // Viet Nam
   'VU',   // Vanuatu
   'WF',   // Wallis and Futuna
   'WS',   // Samoa
   'YE',   // Yemen
   'YT',   // Mayotte
   'ZA',   // South Africa
   'ZM',   // Zambia
   'ZW');  // Zimbabwe

  ISO_3166_1_alpha_2_str   : Array[0..ISO_3166_1_alpha_2_Count-1] of String =
  ('Andorra',
   'United Arab Emirates',
   'Afghanistan',
   'Antigua and Barbuda',
   'Anguilla',
   'Albania',
   'Armenia',
   'Angola',
   'Antarctica',
   'Argentina',
   'American Samoa',
   'Austria',
   'Australia',
   'Aruba',
   'Aland Islands',
   'Azerbaijan',
   'Bosnia and Herzegovina',
   'Barbados',
   'Bangladesh',
   'Belgium', 	
   'Burkina Faso',
   'Bulgaria',
   'Bahrain',
   'Burundi',
   'Benin',
   'Saint Barthelemy',
   'Bermuda',
   'Brunei Darussalam',
   'Bolivia, Plurinational State of',
   'Bonaire, Sint Eustatius and Saba',
   'Brazil',
   'Bahamas',
   'Bhutan',
   'Bouvet Island',
   'Botswana',
   'Belarus',
   'Belize',
   'Canada',
   'Cocos (Keeling) Islands',
   'Congo, the Democratic Republic of',
   'Central African Republic',
   'Congo',
   'Switzerland',
   'Cote d''Ivoire',
   'Cook Islands',
   'Chile',
   'Cameroon',
   'China',
   'Colombia',
   'Costa Rica',
   'Cuba',
   'Cabo Verde',
   'Curacao',
   'Christmas Island',
   'Cyprus',
   'Czechia',
   'Germany',
   'Djibouti',
   'Denmark',
   'Dominica',
   'Dominican Republic',
   'Algeria',
   'Ecuador',
   'Estonia',
   'Egypt',
   'Western Sahara',
   'Eritrea',
   'Spain',
   'Ethiopia',
   'Finland',
   'Fiji',
   'Falkland Islands (Malvinas)',
   'Micronesia, Federated States of',
   'Faroe Islands',
   'France',
   'Gabon',
   'United Kingdom of Great Britain and Northern Ireland',
   'Grenada',
   'Georgia',
   'French Guiana',
   'Guernsey',
   'Ghana',
   'Gibraltar',
   'Greenland',
   'Gambia',
   'Guinea',
   'Guadeloupe',
   'Equatorial Guinea',
   'Greece',
   'South Georgia and the South Sandwich Islands',
   'Guatemala',
   'Guam',
   'Guinea-Bissau',
   'Guyana',
   'Hong Kong',
   'Heard Island and McDonald Islands',
   'Honduras',
   'Croatia',
   'Haiti',
   'Hungary',
   'Indonesia',
   'Ireland',
   'Israel',
   'Isle of Man',
   'India',
   'British Indian Ocean Territory',
   'Iraq',
   'Iran, Islamic Republic of',
   'Iceland',
   'Italy',
   'Jersey',
   'Jamaica',
   'Jordan',
   'Japan',
   'Kenya',
   'Kyrgyzstan',
   'Cambodia',
   'Kiribati',
   'Comoros',
   'Saint Kitts and Nevis',
   'Korea, Democratic People''s Republic of',
   'Korea, Republic of',
   'Kuwait',
   'Cayman Islands',
   'Kazakhstan',
   'Lao People''s Democratic Republic',
   'Lebanon',
   'Saint Lucia',
   'Liechtenstein',
   'Sri Lanka',
   'Liberia',
   'Lesotho',
   'Lithuania',
   'Luxembourg',
   'Latvia',
   'Libya',
   'Morocco',
   'Monaco',
   'Moldova, Republic of',
   'Montenegro',
   'Saint Martin (French part)',
   'Madagascar',
   'Marshall Islands',
   'Macedonia, the former Yugoslav Republic of',
   'Mali',
   'Myanmar',
   'Mongolia',
   'Macao',
   'Northern Mariana Islands',
   'Martinique',
   'Mauritania',
   'Montserrat',
   'Malta',
   'Mauritius',
   'Maldives',
   'Malawi',
   'Mexico',
   'Malaysia',
   'Mozambique',
   'Namibia',
   'New Caledonia',
   'Niger',
   'Norfolk Island',
   'Nigeria',
   'Nicaragua',
   'Netherlands',
   'Norway',
   'Nepal',
   'Nauru',
   'Niue',
   'New Zealand',
   'Oman',
   'Panama',
   'Peru',
   'French Polynesia',
   'Papua New Guinea',
   'Philippines',
   'Pakistan',
   'Poland',
   'Saint Pierre and Miquelon',
   'Pitcairn',
   'Puerto Rico',
   'Palestine, State of',
   'Portugal',
   'Palau',
   'Paraguay',
   'Qatar',
   'Reunion',
   'Romania',
   'Serbia',
   'Russian Federation',
   'Rwanda',
   'Saudi Arabia',
   'Solomon Islands',
   'Seychelles',
   'Sudan',
   'Sweden',
   'Singapore',
   'Saint Helena, Ascension and Tristan da Cunha',
   'Slovenia',
   'Svalbard and Jan Mayen',
   'Slovakia',
   'Sierra Leone',
   'San Marino',
   'Senegal',
   'Somalia',
   'Suriname',
   'South Sudan',
   'Sao Tome and Principe',
   'El Salvador',
   'Sint Maarten (Dutch part)',
   'Syrian Arab Republic',
   'Swaziland',
   'Turks and Caicos Islands',
   'Chad',
   'French Southern Territories',
   'Togo',
   'Thailand',
   'Tajikistan',
   'Tokelau',
   'Timor-Leste',
   'Turkmenistan',
   'Tunisia',
   'Tonga',
   'Turkey',
   'Trinidad and Tobago',
   'Tuvalu',
   'Taiwan, Province of China',
   'Tanzania, United Republic of',
   'Ukraine',
   'Uganda',
   'United States Minor Outlying Islands',
   'United States of America',
   'Uruguay',
   'Uzbekistan',
   'Holy See',
   'Saint Vincent and the Grenadines',
   'Venezuela, Bolivarian Republic of',
   'Virgin Islands, British',
   'Virgin Islands, U.S.',
   'Viet Nam',
   'Vanuatu',
   'Wallis and Futuna',
   'Samoa',
   'Yemen',
   'Mayotte',
   'South Africa',
   'Zambia',
   'Zimbabwe');
   
implementation


end.
