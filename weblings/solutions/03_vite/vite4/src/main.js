import { price } from '@/utils/format.js';
import { Button } from '@components/Button.js';

document.querySelector('#app').append(Button(`Buy for ${price(12.5)}`));
