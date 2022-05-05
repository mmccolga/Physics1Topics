using UnityEngine.Events;

namespace Neuroscience
{
    public static class NeuroscienceEvents
    {
        public static readonly EnableKIonsEvent EnableKIons = new EnableKIonsEvent();
    
        public class EnableKIonsEvent : UnityEvent { }
    }
}
