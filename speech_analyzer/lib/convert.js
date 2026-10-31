import { pipeline } from '@huggingface/transformers';

const transcriber = await pipeline('automatic-speech-recognition', 'Xenova/whisper-tiny.en');
const url = 'https://huggingface.co/datasets/Xenova/transformers.js-docs/resolve/main/jfk.wav';
const output = await transcriber(url);