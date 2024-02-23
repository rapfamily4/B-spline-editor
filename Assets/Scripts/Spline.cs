using System.Collections.Generic;
using UnityEngine.Events;
using UnityEngine;
using Unity.VisualScripting;
using System.Collections;

public class UnityEventFloatList : UnityEvent<List<float>> {}

public class Spline : MonoBehaviour {
    [HideInInspector] public UnityEventFloatList knotGenerationFinished;
    [HideInInspector] public UnityEventFloatList knotVectorSorted;

    public enum KnotsGenerationMode {
        Unclamped,
        Clamped,
        ClampedAveraged,
    }

    public const int CONTROL_POINTS_COUNT = 10; // n
    // m = n + k = knots.size - 1

    public Draggable controlPointPrefab;
    public Transform knotMarkerPrefab;
    public int degree {
        get { return m_degree; }
        set { 
            m_degree = value;
            GenerateKnots(true);
        }
    }
    public int resolution {
        get { return m_resolution; }
        set {
            m_resolution = value;
            UpdateCurve();
        }
    }
    public KnotsGenerationMode knotsGenerationMode = KnotsGenerationMode.Unclamped;

    private LineRenderer m_lineRenderer;
    private GameObject m_controlPointsTree;
    private GameObject m_knotMarkersTree;
    [Range(1, 9)] private int m_degree = 2; // k
    [Range(2, 1024)] private int m_resolution = 96;
    private List<float> m_knots; // It must be normalized in the interval [0, 1].
    private float m_evaluationMin = float.NegativeInfinity; // a
    private float m_evaluationMax = float.PositiveInfinity; // b


    private void Awake() {
        knotGenerationFinished = new UnityEventFloatList();
        knotVectorSorted = new UnityEventFloatList();
        m_lineRenderer = GetComponent<LineRenderer>();
        m_controlPointsTree = new GameObject("ControlPoints");
        m_controlPointsTree.transform.parent = transform;
        m_knotMarkersTree = new GameObject("KnotMarkers");
        m_knotMarkersTree.transform.parent = transform;
        ShowConnectionMarkers(false);

        for (int i = 0; i < CONTROL_POINTS_COUNT; i++) {
            Vector2 viewport = new Vector2(Camera.main.orthographicSize * Camera.main.aspect * 2, Camera.main.orthographicSize * 2);
            float new_x = Mathf.Lerp(-viewport.x * 0.2f, viewport.x * 0.2f, (float)i / (CONTROL_POINTS_COUNT - 1));
            float new_y = Random.Range(-viewport.y * 0.075f, viewport.y * 0.075f);
            Draggable controlPoint = Instantiate(controlPointPrefab, new Vector3(new_x, new_y, 0), Quaternion.identity);
            controlPoint.wasMoved.AddListener(UpdateCurve);
            controlPoint.transform.parent = m_controlPointsTree.transform;
        }

        m_knots = new List<float>();
        GenerateKnots();
    }

    public void GenerateKnots(bool curveUpdatesNextFrame = false) {
        m_knots.Clear();
        for (int i = 0; i < CONTROL_POINTS_COUNT + degree + 1; i++) {
            if (knotsGenerationMode != KnotsGenerationMode.Unclamped) {
                if (i < degree + 1)
                    m_knots.Add(0f);
                else if (i >= CONTROL_POINTS_COUNT && i < CONTROL_POINTS_COUNT + degree + 1)
                    m_knots.Add(1f);
                else if (knotsGenerationMode == KnotsGenerationMode.ClampedAveraged) {
                    // De Boor's parameter averaging; parameters are generated on the fly.
                    float sum = 0f;
                    for (int j = i - degree; j < i; j++)
                        sum += (float)j / (CONTROL_POINTS_COUNT - 1);
                    m_knots.Add(sum / degree);
                } else
                    m_knots.Add((float)(i - degree) / (CONTROL_POINTS_COUNT - degree));
            } else
                m_knots.Add((float)i / (CONTROL_POINTS_COUNT + degree));
            Debug.Log("Generated knot #" + i + ":\t\t" + m_knots[i]);
        }

        m_evaluationMin = m_knots[degree];
        m_evaluationMax = m_knots[CONTROL_POINTS_COUNT];
        Debug.Log("Set evaluation range:\t[" + m_evaluationMin + ", " + m_evaluationMax + "]");

        foreach (Transform knotMarker in m_knotMarkersTree.transform)
            Destroy(knotMarker.gameObject);
        for (int i = 0; i < m_knots.Count - 2 * degree - 2; i++) {
            Transform marker = Instantiate(knotMarkerPrefab);
            marker.transform.parent = m_knotMarkersTree.transform;
        }

        if (curveUpdatesNextFrame)
            StartCoroutine(YieldUpdateNextFrame());
        else
            UpdateCurve();
        knotGenerationFinished.Invoke(m_knots);
    }

    public List<float> GetClonedKnots() {
        return new List<float>(m_knots);
    }

    public void SetKnot(int index, float value) {
        m_knots[index] = value;
        m_knots.Sort();
        m_evaluationMin = m_knots[degree];
        m_evaluationMax = m_knots[CONTROL_POINTS_COUNT];
        knotVectorSorted.Invoke(m_knots);
        UpdateCurve();
    }

    public void ShowConnectionMarkers(bool show) {
        m_knotMarkersTree.SetActive(show);
    }

    public void UpdateCurve() {
        m_lineRenderer.positionCount = 0;
        for (int i = 0; i< resolution; i++) {
            float evaluationPoint = Mathf.Lerp(m_evaluationMin, m_evaluationMax, (float)i / (resolution - 1));
            m_lineRenderer.positionCount += 1;
            m_lineRenderer.SetPosition(m_lineRenderer.positionCount - 1, EvaluateCurve(evaluationPoint));
        }

        for (int i = degree + 1; i < m_knots.Count - degree - 1; i++)
            m_knotMarkersTree.transform.GetChild(i - degree - 1).position = EvaluateCurve(m_knots[i]);
    }

    private Vector3 EvaluateCurve(float evaluationPoint) {
        Debug.Assert(m_evaluationMin < evaluationPoint || Mathf.Approximately(m_evaluationMin, evaluationPoint));
        Debug.Assert(evaluationPoint < m_evaluationMax || Mathf.Approximately(m_evaluationMax, evaluationPoint));
        for (int j = degree; j < CONTROL_POINTS_COUNT; j++)
            if (m_knots[j] <= evaluationPoint && evaluationPoint < m_knots[j + 1])
                return DeBoorCox(j, degree, evaluationPoint);
        return DeBoorCox(CONTROL_POINTS_COUNT - 1, degree, evaluationPoint);
    }

    private float Aux(int i, int j, float evaluationPoint) {
        if (m_knots[i] < m_knots[i + degree + 1 - j])
            return (evaluationPoint - m_knots[i]) / (m_knots[i + degree + 1 - j] - m_knots[i]);
        return 0f;
    }

    private Vector3 DeBoorCox(int i, int j, float evaluationPoint) {
        Debug.Assert(0 <= i && i < CONTROL_POINTS_COUNT);
        Debug.Assert(0 <= j && j <= degree);
        if (j == 0)
            return m_controlPointsTree.transform.GetChild(i).position;
        float auxVal = Aux(i, j, evaluationPoint);
        Vector3 deBoor0 = DeBoorCox(i, j - 1, evaluationPoint);
        Vector3 deBoor1 = DeBoorCox(i - 1, j - 1, evaluationPoint);
        return auxVal * deBoor0 + (1 - auxVal) * deBoor1;
    }

    private IEnumerator YieldUpdateNextFrame() {
        yield return new WaitForEndOfFrame();
        UpdateCurve();
    }
}
