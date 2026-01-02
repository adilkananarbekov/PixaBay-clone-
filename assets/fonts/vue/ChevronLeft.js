import { defineComponent, h } from 'vue';

export const ChevronLeft = defineComponent({
  name: 'ChevronLeft',
  props: {
    class: {
      type: String,
      default: ''
    }
  },
  setup(props, { attrs }) {
    return () => h(
      'svg',
      {
        viewBox: '0 0 20 20',
        
        class: `app_icons ${props.class}`,
        ...attrs
      },
      [
        h('path', {"d": "M13.3334 17.2917C13.1675 17.2925 13.0083 17.2264 12.8917 17.1083L6.22502 10.4417C5.98131 10.1977 5.98131 9.80236 6.22502 9.55835L12.8917 2.89168C13.1379 2.66222 13.5217 2.66899 13.7597 2.907C13.9977 3.14501 14.0045 3.52876 13.775 3.77501L7.55002 10L13.775 16.225C14.0187 16.469 14.0187 16.8643 13.775 17.1083C13.6584 17.2264 13.4992 17.2925 13.3334 17.2917Z", "fillRule": "evenodd"})
      ]
    );
  }
});
